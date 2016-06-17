class CreateBlogPosts < ActiveRecord::Migration

  create_table(:shoppe_blog_posts) do |t|
    t.string   :permalink    , null: false
    t.string   :title        , null: false
    t.boolean  :published    , null: false
    t.datetime :published_at , null: false

    t.string   :markup_lang  , null: false
    t.text     :raw_content  , null: false

    t.text     :html_content , null: false
    t.text     :html_overview, null: true

    t.string   :tags_string      , null: true
    t.string   :meta_description , null: false
    t.string   :meta_image       , null: true

    t.timestamps
  end

  add_index :shoppe_blog_posts, :permalink, unique: true
  add_index :shoppe_blog_posts, :published_at
end
