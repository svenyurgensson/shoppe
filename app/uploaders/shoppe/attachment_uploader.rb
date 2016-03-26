# encoding: utf-8

class Shoppe::AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Where should files be stored?
  def store_dir
    "attachment/#{model.id}"
  end

  # Returns true if the file is an image
  def image?(file)
    file.content_type.include? 'image'
  end

  # Returns true if the file is not an image
  def not_image?(file)
    !file.content_type.include? 'image'
  end

  #process :watermark

  # Create different versions of your uploaded files:
  version :thumb, if: :image? do
    process resize_and_pad: [200, 200]
    #process :watermark
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  def watermark
    return unless file.content_type.include? 'image'
    return unless File.readable?("#{Rails.root}/public/watermark.png")

    manipulate! do |img|
      mark = MiniMagick::Image.open("#{Rails.root}/public/watermark.png")
      img = img.composite(mark) do |c|
        c.gravity 'center'
        c.geometry '800x'
        c.compose 'Over'
      end
    end
  end
end
