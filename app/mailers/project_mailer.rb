# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  default from: 'mailer@openhub.net'

  def report_outdated(account, project)
    @account = account
    @project = project
    mail to: 'info@openhub.net', subject: "#{@project.name} is outdated"
  end
end
