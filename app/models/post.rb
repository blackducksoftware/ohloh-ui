class Post < ActiveRecord::Base
  include Tsearch
  belongs_to :forum, counter_cache: true
  belongs_to :topic, inverse_of: :posts, counter_cache: true, touch: true
  belongs_to :account

  validates :body, :topic, presence: true
  # Popularity_factor is not increasing at all. Get antoher pair of eyes
  # all posts in the database are set at 0.05
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

  def destroy_with_empty_topic
    destroy
    return if topic.forum_id.nil? || topic.posts.exists?
    topic.destroy
  end
end
