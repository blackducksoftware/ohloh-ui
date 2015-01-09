class PostNotifier < ActionMailer::Base
  default from: 'ohlohadmins@blackducksoftware.com'

  def post_creation_notification(user_who_replied, topic)
     #TODO: Make sure that the subject and body are internationalized and encoded correctly
    @user_who_replied = user_who_replied
    @topic = topic
    mail(to: @user_who_replied.email, subject: "Post successfully created", template_path: 'mailers', template_name: 'post_notifier')
  end

  def post_replied_notification(user, user_who_replied, topic)
    @user_who_needs_reply = user
    @user_who_replied = user_who_replied
    @topic = topic
    mail(to: @user_who_needs_reply.email, subject: "Someone has responded to your post", template_path: 'mailers', template_name: 'reply_notifier')
  end
end