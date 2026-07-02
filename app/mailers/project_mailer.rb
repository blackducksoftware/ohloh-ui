# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  default from: ENV.fetch('MAILER_SENDER')

  def report_outdated(account, project)
    @account = account
    @project = project
    mail to: ENV.fetch('SUPPORT_EMAIL'), subject: "#{@project.name} is outdated"
  end
end
