class CreateTags < ActiveRecord::Migration
  def change
    create_table :shoppe_blog_tags do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :shoppe_blog_tags, :name, unique: true
  end
end
