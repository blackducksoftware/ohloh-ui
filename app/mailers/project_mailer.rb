# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  def report_outdated(account, project)
    @project = project
    mail to: 'info@openhub.net', from: account.email, subject: "#{@project.name} is outdated"
  end
end
