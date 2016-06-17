class CreateBlogTaggings < ActiveRecord::Migration
  def change
    taggings_table = :shoppe_blog_taggings

    create_table(taggings_table) do |t|
      t.integer :post_id, null: false
      t.integer :tag_id , null: false
    end

    add_index taggings_table, [:tag_id, :post_id], unique: true
  end
end
