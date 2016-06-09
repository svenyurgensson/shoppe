class AddBillingInfoJson < ActiveRecord::Migration
  def change
    add_column :shoppe_customers, :business_details, :jsonb
  end
end
