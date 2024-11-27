class Document < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :name, presence: true
  validates :cloudinary_id, presence: true, if: -> { file.present? }

  attr_accessor :file

  def image?
    return false unless cloudinary_id.present?
    %w[jpg jpeg gif png webp].include?(format)
  end

  def pdf?
    return false unless cloudinary_id.present?
    format == 'pdf'
  end

  def previewable?
    image? || pdf?
  end

  def format
    return nil unless cloudinary_id.present?
    Cloudinary::Api.resource(cloudinary_id)['format']
  rescue => e
    Rails.logger.error "Cloudinary error: #{e.message}"
    nil
  end

  def preview_url
    return nil unless cloudinary_id.present? && previewable?
    if image?
      Cloudinary::Utils.cloudinary_url(cloudinary_id, width: 200, crop: :fit)
    else # pdf
      Cloudinary::Utils.cloudinary_url(cloudinary_id, format: 'jpg', width: 200, crop: :fit, page: 1)
    end
  end
end
