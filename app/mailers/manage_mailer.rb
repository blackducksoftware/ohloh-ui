# frozen_string_literal: true

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

  class << self
    def deliver_emails(manage)
      return if manage.changed.blank?

      %i[check_automatic_approval check_removed check_approved check_applied].each do |message|
        break if send(message, manage)
      end
      send(:check_rejection, manage)
    end
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

  class << self
    def check_automatic_approval(manage)
      return false unless manage.approved_by == Account.hamster.id && !manage.deleted_by

      automatic_approval(manage).deliver_now
      true
    end

    def check_removed(manage)
      return false unless manage.changed.include?('deleted_by')

      manage.target.active_managers.each { |manager| deliver_deletion(manager, manage) }
      true
    end

    def deliver_deletion(manager, manage)
      if manage.approver.nil?
        method = manage.destroyer == manage.account ? :withdrawn : :denied
        send(method, manager, manage).deliver_now
      else
        removed(manager, manage).deliver_now
      end
    end

    def check_approved(manage)
      return false unless manage.changed.include?('approved_by') && manage.approver

      manage.target.active_managers.each do |manager|
        approved(manager, manage).deliver_now
      end
      true
    end

    def check_applied(manage)
      return false unless manage.changed.include?('account_id') && manage.account

      manage.target.active_managers.each do |manager|
        applied(manager, manage).deliver_now
      end
      true
    end

    def check_rejection(manage)
      return false if !manage.changed.include?('deleted_by') || manage.deleted_by.blank?
      return false if manage.destroyer == manage.account

      manage.approver ? removal(manage).deliver_now : rejection(manage).deliver_now
    end
  end
end
