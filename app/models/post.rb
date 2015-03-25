class Post < ActiveRecord::Base
  include Tsearch
  belongs_to :topic, inverse_of: :posts
  belongs_to :forum, counter_cache: true
  belongs_to :topic, inverse_of: :posts, counter_cache: true
  belongs_to :account

  validates :body, :topic, presence: true
  validates :popularity_factor, numericality: true, allow_blank: true

  scope :by_newest, -> { order('posts.created_at desc') }
  scope :by_unanswered, -> { joins(:topic).where(topics: { posts_count: 1 }).by_newest }

  def body=(value)
    super(value ? value.fix_encoding_if_invalid!.strip_tags.strip : nil)
  end

  def searchable_factor
    0.05
  end

  def searchable_vector
    {
      b: topic.title,
      d: body
    }
  end
end
