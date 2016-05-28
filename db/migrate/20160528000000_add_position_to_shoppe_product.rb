class AddPositionToShoppeProduct < ActiveRecord::Migration
  def change
    add_column :shoppe_products, :position, :integer, default: 0
  end
end
