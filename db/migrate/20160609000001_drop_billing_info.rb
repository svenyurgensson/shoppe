class DropBillingInfo < ActiveRecord::Migration
  def change
    remove_column :shoppe_customers, :business_details
  end
end
