class Shoppe::Blog::Tagging < ActiveRecord::Base
  self.table_name = 'shoppe_blog_taggings'

  belongs_to :post, class_name: '::Shoppe::Blog::Post'
  belongs_to :tag, class_name: '::Shoppe::Blog::Tag'
end
