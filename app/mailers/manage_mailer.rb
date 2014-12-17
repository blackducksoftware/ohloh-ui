class ManageMailer < ActionMailer::Base
  default to: proc { (@manager || @manage.account).email },
          from: 'mailer@openhub.net'

  def rejection(manage)
    @manage = manage
    mail subject: t('.subject', target: target)
  end

  def automatic_approval(manage)
    @manage = manage
    mail subject: t('.subject', target: target)
  end

  def withdrawn(manager, manage)
    @manager = manager
    @manage = manage
    mail subject: t('.subject', target: target, name: name)
  end

  def approved(manager, manage)
    @manager = manager
    @manage = manage
    mail subject: t('.subject', target: target, approver: @manage.approver.name, name: name)
  end

  def applied(manager, manage)
    @manager = manager
    @manage = manage
    mail subject: t('.subject', target: target, name: name)
  end

  def denied(manager, manage)
    @manager = manager
    @manage = manage
    mail subject: t('.subject', target: target, destroyer: destroyer, name: name)
  end

  def removed(manager, manage)
    @manager = manager
    @manage = manage
    mail subject: t('.subject', target: target, destroyer: destroyer, name: name)
  end

  def removal(manage)
    @manage = manage
    mail subject: t('.subject', target: target, destroyer: destroyer, target_type: @manage.target_type.downcase)
  end

  private

  def target
    @manage.target.name
  end

  def destroyer
    @manage.destroyer.name
  end

  def name
    @manage.account.name
  end
end
