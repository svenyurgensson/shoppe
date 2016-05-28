# encoding: utf-8

class Shoppe::AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  # Where should files be stored?
  def store_dir
    "attachment/#{model.id}"
  end

  after :remove, :delete_empty_upstream_dirs

  # Returns true if the file is an image
  def image?(file)
    file.content_type.include? 'image'
  end

  # Returns true if the file is not an image
  def not_image?(file)
    !file.content_type.include? 'image'
  end


  # Create different versions of your uploaded files:
  version :large, if: :image? do
    process watermark: '900x'
    process :optimize_image
    process resize_to_limit: [900, 800]
  end

  # Create different versions of your uploaded files:
  version :thumb, if: :image? do # , from_version: :large
    process :optimize_image
    process resize_and_pad: [300, 300]
    process watermark: '300x'
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  def watermark(geo = '900x')
    return unless file.content_type.include? 'image'
    return unless File.readable?("#{Rails.root}/public/watermark.png")

    manipulate! do |img|
      mark = MiniMagick::Image.open("#{Rails.root}/public/watermark.png")
      img = img.composite(mark) do |c|
        c.gravity 'center'
        c.geometry geo
        c.compose 'Over'
      end
    end
  end

  def optimize_image
    manipulate! do |img|
      img.format('JPEG')
      img = img.auto_orient
      img = img.quality(80)
      img.fuzz '3%'
      img
    end
  end

  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) # fails if path not empty dir
  rescue SystemCallError
    true # nothing, the dir is not empty
  end

end
