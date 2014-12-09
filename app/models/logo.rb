class Logo < Attachment
  FILE_SIZE_LIMIT = 1..500.kilobytes
  attr_reader :url

  has_one :project
  has_one :organization

  has_attached_file :attachment, styles: { tiny: '16x16', small: '32x32', med: '64x64' }, default_style: ''

  validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\Z/,
                                                 message: I18n.t('logos.invalid_content_type')
  validates_attachment_size :attachment, in: FILE_SIZE_LIMIT, message: I18n.t('logos.invalid_file_size')

  alias_attribute :attachment_file_name, :filename
  alias_attribute :attachment_file_size, :size
  alias_attribute :attachment_content_type, :content_type

  validates :attachment_file_name, presence: true
  validate { errors.add(:url, I18n.t('logos.invalid_url')) if @invalid_url }

  def url=(uri)
    self.attachment = uri unless uri.blank?
  rescue
    @invalid_url = true
  end

  class << self
    def default_file_name(style = :med)
      case style
      when :tiny
        'no_logo_16.png'
      when :small
        'no_logo_32.png'
      else
        'no_logo.png'
      end
    end
  end

  Paperclip.interpolates :style do |_attachment, style|
    style.blank? ? '' : "_#{style}"
  end
end
