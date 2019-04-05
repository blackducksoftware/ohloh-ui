class CompareProjectCsvDecorator
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include ProjectsHelper

  def initialize(project, host)
    @project = project
    @host = host
    @url_decorator = CompareProjectUrlCsvDecorator.new(project, host)
    @analysis_decorator = CompareProjectAnalysisCsvDecorator.new(project)
  end

  def activity
    project_activity_text(@project, false).strip
  end

  def user_count
    pluralize_with_delimiter(@project.user_count, t('compares.user'))
  end

  def rating_average
    number_with_precision(@project.rating_average || 0, precision: 1)
  end

  def rating_count
    @project.ratings.count
  end

  def licenses
    licenses = @project.licenses
    return t('compares.no_data') if licenses.blank?

    licenses.map { |license| "#{license.short_name} #{h.license_url(license, host: @host)}" }.join(', ')
  end

  def managers
    managers = @project.active_managers
    return t('compares.position_not_yet_claimed') if managers.blank?

    managers.map { |account| "#{account.name} #{h.account_url(account, host: @host)}" }.join(', ')
  end

  def t(*args)
    I18n.t(*args)
  end

  def method_missing(method, *args)
    return @url_decorator.send(method, *args) if @url_decorator.respond_to?(method)
    return @analysis_decorator.send(method, *args) if @analysis_decorator.respond_to?(method)
    return @project.send(method, *args) if @project.respond_to?(method)

    super
  end

  def respond_to_missing?(method)
    @url_decorator.respond_to?(method) ||
      @analysis_decorator.respond_to?(method) ||
      @project.respond_to?(method)
  end

  private

  def h
    Rails.application.routes.url_helpers
  end
end
