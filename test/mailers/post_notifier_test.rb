require 'test_helper'

class PostNotifierTest < ActionMailer::TestCase
  it 'user who originally created the first post for a topic should receive a post creation email' do
    email = PostNotifier.post_creation_notification(accounts(:admin), topics(:sticky)).deliver
    email.to.must_equal [accounts(:admin).email] # Admin Allen
    email[:from].value.must_equal 'ohlohadmins@blackducksoftware.com'
    email.subject.must_equal 'Post successfully created'
    expected = "Hello #{accounts(:admin).name}, your post has been successfully created under #{topics(:sticky).title}"
    email.body.encoded.must_match expected
    ActionMailer::Base.deliveries.wont_be :empty?
    ActionMailer::Base.deliveries.size.must_equal 1
  end

  it 'user who replied should receive a post replied notification email' do
    user1 = accounts(:admin)
    user2 = create(:account)
    topic = topics(:galactus)
    email = PostNotifier.post_replied_notification(user1, user2, topic).deliver
    email.to.must_equal [user1.email] # Admin Allen
    email[:from].value.must_equal 'ohlohadmins@blackducksoftware.com'
    email.subject.must_equal 'Someone has responded to your post'
    email.body.encoded.must_match "Hello #{user1.name}, #{user2.name} has replied to your post under #{topic.title}"

    ActionMailer::Base.deliveries.wont_be :empty?
    ActionMailer::Base.deliveries.size.must_equal 1
  end
end
