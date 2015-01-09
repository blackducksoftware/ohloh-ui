class Post < ActiveRecord::Base
  belongs_to :topic, inverse_of: :posts
  belongs_to :account
 
  validates :body, :account, :topic, presence: true
  validates :popularity_factor, numericality: true, allow_blank: true

  def body=(value)
  	super(value ? value.fix_encoding_if_invalid!.strip_tags.strip : nil)
  end
end
