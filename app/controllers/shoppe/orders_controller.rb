# coding: utf-8
require 'csv'
module Shoppe
  class OrdersController < Shoppe::ApplicationController
    before_filter { @active_nav = :orders }
    before_filter { params[:id] && @order = Shoppe::Order.find(params[:id]) }

    def index
      respond_to do |format|
        format.html do
          @query =
            Shoppe::Order
            .ordered
            .received
            .includes(:customer, :delivery_service)
            .includes(order_items: :ordered_item)
            .page(params[:page])
            .search(params[:q])
          @orders = @query.result
          render
        end
        format.csv do
          send_data orders_csv, filename: "orders-#{Date.today}.csv"
        end
      end
    end

    def new
      @order = Shoppe::Order.new
      @order.order_items.build(ordered_item_type: 'Shoppe::Product')
    end

    def create
      Shoppe::Order.transaction do
        @order = Shoppe::Order.new(safe_params)
        @order.status = 'confirming'

        if safe_params[:customer_id]
          @customer = Shoppe::Customer.find safe_params[:customer_id]
          @order.first_name = @customer.first_name
          @order.last_name = @customer.last_name
          @order.company = @customer.company
          @order.email_address = @customer.email
          @order.phone_number = @customer.phone
          if @customer.addresses.billing.present?
            billing = @customer.addresses.billing.first
            @order.billing_address1 = billing.address1
            @order.billing_address2 = billing.address2
            @order.billing_address3 = billing.address3
            @order.billing_address4 = billing.address4
            @order.billing_postcode = billing.postcode
            @order.billing_country_id = billing.country_id
          end
          if @customer.addresses.delivery.present?
            delivery = @customer.addresses.delivery.first
            @order.delivery_address1 = delivery.address1
            @order.delivery_address2 = delivery.address2
            @order.delivery_address3 = delivery.address3
            @order.delivery_address4 = delivery.address4
            @order.delivery_postcode = delivery.postcode
            @order.delivery_country_id = delivery.country_id
          end
        end

        if !request.xhr? && @order.save
          @order.confirm!
          redirect_to @order, flash: { notice: t('shoppe.orders.create_notice') }
        else
          @order.order_items.build(ordered_item_type: 'Shoppe::Product')
          render action: 'new'
        end
      end
    rescue Shoppe::Errors::InsufficientStockToFulfil => e
      flash.now[:alert] = t('shoppe.orders.insufficient_stock_order', out_of_stock_items: e.out_of_stock_items.map { |t| t.ordered_item.full_name }.to_sentence)
      render action: 'new'
    end

    def show
      @payments = @order.payments.to_a
    end

    def update
      @order.attributes = safe_params
      if !request.xhr? && @order.update_attributes(safe_params)
        redirect_to @order, flash: { notice: t('shoppe.orders.update_notice') }
      else
        render action: 'edit'
      end
    end

    def search
      index
      render action: 'index'
    end

    def accept
      @order.accept!(current_user)
      redirect_to @order, flash: { notice: t('shoppe.orders.accept_notice') }
    rescue Shoppe::Errors::PaymentDeclined => e
      redirect_to @order, flash: { alert: e.message }
    end

    def reject
      @order.reject!(current_user)
      redirect_to @order, flash: { notice: t('shoppe.orders.reject_notice') }
    rescue Shoppe::Errors::PaymentDeclined => e
      redirect_to @order, flash: { alert: e.message }
    end

    def ship
      @order.ship!(params[:consignment_number], current_user)
      redirect_to @order, flash: { notice: t('shoppe.orders.ship_notice') }
    end

    def despatch_note
      render layout: 'shoppe/printable'
    end

    def checkout
      @order.confirm!
      redirect_to @order
    end

    def xls
      created = I18n.l(@order.created_at, format: :short).gsub(/[,.'"]/,'').gsub(/\s+/, '-')
      headers['Content-Type'] = 'application/vnd.ms-excel'
      headers['Content-Disposition'] = "attachment; filename=\"заказ_#{@order.number}_#{created}.xls\""
      headers['Cache-Control'] = ''

      render :xls, layout: false
    end

    private

    def orders_csv
      query = Shoppe::Order.ordered.received
      result = CSV.generate(headers: true) do |csv|
        csv << %w(дата номер статус клиент сумма платеж товар количество себестоимость цена)
        query.each_with_index do |o, idx|
          o.order_items.each do |i|
            res = nil
            if idx == 0
              res = [
                I18n.l(o.created_at, format: :long),
                o.number,
                I18n.t("shoppe.orders.statuses.#{o.status}"),
                o.full_name,
                o.total,
                o.amount_paid,
                i.ordered_item.full_name,
                i.quantity,
                i.total_cost,
                i.total
              ]
            else
              res = [
                nil, nil, nil, nil, nil, nil,
                i.ordered_item.full_name,
                i.quantity,
                i.total_cost,
                i.total
              ]
            end
            csv << res
          end
        end
      end
      result
    end


    def safe_params
      params[:order].permit(
        :customer_id,
        :first_name, :last_name, :company,
        :billing_address1, :billing_address2, :billing_address3, :billing_address4, :billing_postcode, :billing_country_id,
        :separate_delivery_address,
        :delivery_name, :delivery_address1, :delivery_address2, :delivery_address3, :delivery_address4, :delivery_postcode, :delivery_country_id,
        :delivery_price, :delivery_service_id, :delivery_tax_amount,
        :email_address, :phone_number,
        :notes,
        order_items_attributes: [:ordered_item_id, :ordered_item_type, :quantity, :unit_price, :tax_amount, :id, :weight]
      )
    end
  end
end
