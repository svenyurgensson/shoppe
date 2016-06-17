class Shoppe::Blog::Tag < ActiveRecord::Base
  self.table_name = 'shoppe_blog_tags'

  has_many :taggings, class_name: '::Shoppe::Blog::Tagging'
  has_many :posts, through: :taggings

  default_scope { order('name ASC') }

  validates :name, presence: true

  def to_param
    name
  end
end
