require 'test_helper'

class PostNotifierTest < ActionMailer::TestCase
  fixtures :accounts, :topics, :posts

  test 'user who originally created the first post for a topic should receive a post creation email' do
    email = PostNotifier.post_creation_notification(accounts(:admin), topics(:sticky)).deliver
    assert_equal [accounts(:admin).email], email.to # Admin Allen
    assert_equal 'ohlohadmins@blackducksoftware.com', email[:from].value
    assert_equal 'Post successfully created', email.subject
    expected = "Hello #{accounts(:admin).name}, your post has been successfully created under #{topics(:sticky).title}"
    assert_match expected, email.body.encoded
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'user who replied should receive a post replied notification email' do
    user1 = accounts(:admin)
    user2 = accounts(:user)
    topic = topics(:galactus)
    email = PostNotifier.post_replied_notification(user1, user2, topic).deliver
    assert_equal [user1.email], email.to # Admin Allen
    assert_equal 'ohlohadmins@blackducksoftware.com', email[:from].value
    assert_equal 'Someone has responded to your post', email.subject
    assert_match "Hello #{user1.name}, #{user2.name} has replied to your post under #{topic.title}",
                 email.body.encoded
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end
