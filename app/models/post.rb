# frozen_string_literal: true

class Post < ApplicationRecord
  include Tsearch
  belongs_to :forum, counter_cache: true, optional: true
  belongs_to :topic, inverse_of: :posts, counter_cache: true, touch: true, optional: true
  belongs_to :account, optional: true

  validates :body, :topic, presence: true
  # Popularity_factor is not increasing at all. Get antoher pair of eyes
  # all posts in the database are set at 0.05
  validates :popularity_factor, numericality: true, allow_blank: true

  scope :by_newest, -> { order('posts.created_at desc') }
  scope :by_unanswered, -> { joins(:topic).where(topics: { posts_count: 1 }).by_newest }
  # DISTINCT ON is a Postgres extension to the SQL standard so it won't work on other databases.
  scope :most_recent, lambda {
    joins("INNER JOIN (
            SELECT DISTINCT ON (topic_id) topic_id, id FROM posts ORDER BY topic_id, created_at DESC
          ) most_recent ON (most_recent.id=posts.id)")
  }
  scope :open_topics, -> { joins(:topic).where(topics: { closed: false }).by_newest }

  after_destroy :update_topic
  after_save :update_topic_with_post_data, if: :saved_change_to_body?

  def update_topic_with_post_data
    topic.update(replied_at: updated_at,
                 replied_by: account_id,
                 last_post_id: id)
  end

  def update_topic
    if topic.reload.posts_count.zero?
      topic.destroy
    else
      last_post = topic.posts.last
      topic.update(replied_at: last_post.created_at,
                   replied_by: last_post.account_id,
                   last_post_id: last_post.id)
    end
  end

  def body=(value)
    super(value ? value.fix_encoding_if_invalid.strip_tags.strip : nil)
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
