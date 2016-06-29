class CreatePasswordResets < ActiveRecord::Migration
  def change
    create_table :shoppe_password_resets do |t|
      t.belongs_to :customer, index: true
      t.string :token

      t.timestamps
    end
  end
end
