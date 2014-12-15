class Post < ActiveRecord::Base
  belongs_to :topic, inverse_of: :posts
  belongs_to :account
 
  validates :body, :account, :topic, presence: true
  validates :popularity_factor, numericality: true, allow_blank: true

  after_create do |post|
    #Re-check the database null constraints, doesn't seem to add up
    #increment_counter relates to counter cache
    Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?',post.created_at, post.account_id, post.id])
    Forum.increment_counter('posts_count', post.topic.forum_id) if post.topic.forum_id
  end

  after_destroy do |post|
    #Re-check the database null constraints, doesn't seem to add up
    #decrement_counter relates to counter cache
    topic = post.topic
    Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', topic.posts.last.created_at, topic.posts.last.account_id, topic.posts.last.id]) if topic && topic.posts.last
    Forum.decrement_counter('posts_count', topic.forum_id) if post.topic.forum_id
  end

  def body=(value)
  	super(value ? value.fix_encoding_if_invalid!.strip_tags.strip : nil)
  end
end
