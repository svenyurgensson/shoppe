class AddPasswordDigestToCustomer < ActiveRecord::Migration
  def change
    add_column :shoppe_customers, :password_digest, :string
  end
end
