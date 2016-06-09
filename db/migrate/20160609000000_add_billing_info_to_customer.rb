class AddBillingInfoToCustomer < ActiveRecord::Migration
  def change
    add_column :shoppe_customers, :business_details, :string
  end
end
