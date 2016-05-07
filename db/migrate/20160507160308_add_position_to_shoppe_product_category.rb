class AddPositionToShoppeProductCategory < ActiveRecord::Migration
  def change
    add_column :shoppe_product_categories, :position, :integer, default: 0
  end
end
