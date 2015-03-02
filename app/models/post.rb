class Post < ActiveRecord::Base
  belongs_to :forum, counter_cache: true
  belongs_to :topic, inverse_of: :posts, counter_cache: true
  belongs_to :account

  validates :body, :topic, presence: true
  validates :popularity_factor, numericality: true, allow_blank: true

  def body=(value)
    super(value ? value.fix_encoding_if_invalid!.strip_tags.strip : nil)
  end
end
