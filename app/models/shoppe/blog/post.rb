class Shoppe::Blog::Post < ActiveRecord::Base
  include FriendlyId

  self.table_name = 'shoppe_blog_posts'

  has_many :taggings, class_name: '::Shoppe::Blog::Tagging'
  has_many :tags, through: :taggings, dependent: :destroy


  validates :title,  :raw_content, presence: true
  validates :permalink, uniqueness: true

  friendly_id :slug_candidates, use: [:slugged, :finders]

  scope :published, -> { where(published: true).where("published_at <= ?", Time.zone.now) }

  default_scope { order('published_at DESC') }

  before_validation :handle_saving

  before_save :set_meta_description, :set_meta_image

  def status
    published? ? 'published' : 'draft'
  end

  # Array of tag names. Storing arrays in +tags_string+ we don't need to make
  # many-to-many join with tags table to get tag names.
  #
  # @return [Array<String>]
  def tag_names
    if tags_string
      tags_string.split(',').map(&:strip)
    else
      []
    end
  end

  def slug_candidates
    [:title]
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end


  def set_tags!(tags_string)
    return unless tags_string.present?

    tag_names = tags_string.split(',').map do |tag_name|
      tag_name.strip.downcase
    end
    tag_names.reject!(&:blank?)

    tag_names.each do |tag_name|
      tag = Shoppe::Blog::Tag.where(name: tag_name).first_or_create
      self.tags << tag unless self.tags.include?(tag)
    end

    self.tags_string = tag_names.join(", ")
  end

  def clear_tags!
    self.tags.destroy_all.each do |tag|
      tag.destroy if tag.posts.count.zero?
    end
  end

  private

  JUMP_BREAK = '<!--more-->'

  def handle_saving
    self.published_at ||= Time.zone.now
    self.markup_lang ||= 'markdown'

    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    overview, rest = self.raw_content.split(JUMP_BREAK, 2)
      if rest.present?
        self.html_overview = renderer.render(overview)
        self.html_content = renderer.render(overview + rest)
      else
        self.html_overview = nil
        self.html_content = renderer.render(self.raw_content)
      end
  end

  # Filter html content to get plain text and set first 200 characters as meta_description.
  #
  # @return [void]
  def set_meta_description
    html = html_overview || html_content || ''

    self.meta_description =
      html.
        gsub(/<\/?[^>]*>/, ' ').  # replace HTML tags with spaces
        gsub(/&\w{1,9};|"/, '').  # remove HTML special chars and double quotes
        gsub(/\n+/, " ").         # remove new lines
        gsub(/\s+/, ' ').         # remove duplicated spaces
        strip[0..200]             # strip spaces and get first 200 chars
  end

  # Find first img tag and in content and grab its source.
  #
  # @return [void]
  def set_meta_image
    regexp = /<img[^>]+src=["']([^"']*)/
    if img_tag = (html_content || '').match(regexp)
      self.meta_image = img_tag[1]
    else
      self.meta_image = nil
    end
  end
end
