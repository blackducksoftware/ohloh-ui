class PostNotifier < ActionMailer::Base
  default from: 'mailer@blackducksoftware.com'

  def post_creation_notification(user_who_replied, topic)
    @user_who_replied = user_who_replied
    @topic = topic
    mail(to: @user_who_replied.email,
         subject: t('.subject'),
         template_path: 'mailers',
         template_name: 'post_notifier')
  end

  def post_replied_notification(user, user_who_replied, post)
    @user_who_needs_reply = user
    @user_who_replied = user_who_replied
    @topic = post.topic
    @post = post
    mail(to: @user_who_needs_reply.email,
         subject: t('.subject'),
         template_path: 'mailers',
         template_name: 'reply_notifier')
  end
end
