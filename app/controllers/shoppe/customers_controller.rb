module Shoppe
  class CustomersController < Shoppe::ApplicationController
    before_filter { @active_nav = :customers }
    before_filter { params[:id] && @customer = Shoppe::Customer.find(params[:id]) }

    def index
      @query = Shoppe::Customer.ordered.page(params[:page]).search(params[:q])
      @customers = @query.result
    end

    def new
      @customer = Shoppe::Customer.new
    end

    def show
      @addresses = @customer.addresses.ordered.load
      @orders = @customer.orders.ordered.load
    end

    def create
      @customer = Shoppe::Customer.new(normalized_customer_params)
      if @customer.save
        redirect_to @customer, flash: { notice: t('shoppe.customers.created_successfully') }
      else
        render action: 'new'
      end
    end

    def update
      if @customer.update(normalized_customer_params)
        redirect_to @customer, flash: { notice: t('shoppe.customers.updated_successfully') }
      else
        render action: 'edit'
      end
    end

    def destroy
      @customer.destroy
      redirect_to customers_path, flash: { notice: t('shoppe.customers.deleted_successfully') }
    end

    def search
      index
      render action: 'index'
    end

    private

    def normalized_customer_params
      pr = safe_customer_params
      bd = pr.slice(*Shoppe::Customer::BUSINESS_ACC)
      {
        first_name: pr[:first_name],
        last_name: pr[:last_name],
        email: pr[:email],
        phone: pr[:phone],
        password: pr[:password],
        company: pr[:company],
        business_details: bd
      }
    end

    def safe_customer_params
      permitted = [
        :first_name,
        :last_name,
        :email,
        :phone,
        :password,
        :password_confirmation,
        :company,
        :business_details
      ] + Shoppe::Customer::BUSINESS_ACC

      params[:customer].permit(*permitted)
    end
  end
end
