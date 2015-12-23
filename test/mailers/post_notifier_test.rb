require 'test_helper'

describe PostNotifier do
  it 'user who originally created the first post for a topic should receive a post creation email' do
    user = create(:account)
    topic = create(:topic)
    before = ActionMailer::Base.deliveries.size
    email = PostNotifier.post_creation_notification(user, topic).deliver_now
    email.to.must_equal [user.email]
    email[:from].value.must_equal 'mailer@blackducksoftware.com'
    email.subject.must_equal 'Post successfully created'
    email.body.encoded.strip_tags.squish.must_match "Dear #{user.name}"
    email.body.encoded.strip_tags.squish.must_match "post has been successfully created under #{topic.title}"
    ActionMailer::Base.deliveries.wont_be :empty?
    (ActionMailer::Base.deliveries.size - before).must_equal 1
  end

  it 'user who replied should receive a post replied notification email' do
    user1 = create(:admin)
    user2 = create(:account)
    post = create(:post)
    topic = post.topic
    before = ActionMailer::Base.deliveries.size
    email = PostNotifier.post_replied_notification(user1, user2, post).deliver_now
    email.to.must_equal [user1.email]
    email[:from].value.must_equal 'mailer@blackducksoftware.com'
    email.subject.must_equal 'Someone has responded to your post'
    email.body.encoded.strip_tags.squish.must_match "Dear #{user1.name}"
    email.body.encoded.strip_tags.squish.must_match "#{user2.name} responded to the forum topic #{topic.title}"
    ActionMailer::Base.deliveries.wont_be :empty?
    (ActionMailer::Base.deliveries.size - before).must_equal 1
  end
end
