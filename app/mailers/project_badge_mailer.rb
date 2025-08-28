# frozen_string_literal: true

class ProjectBadgeMailer < ApplicationMailer
  default from: 'mailer@openhub.net'

  def check_cii_projects(projects)
    @projects = projects
    mail to: ENV.fetch('CII_PROJECTS_EMAIL_RECEIPIENT', nil),
         subject: I18n.t('project_badge_mailer.check_cii_projects.subject', count: @projects.size)
  end
end
