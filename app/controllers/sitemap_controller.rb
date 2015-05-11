class SitemapController < ApplicationController
  skip_before_action :verify_api_access_for_xml_request

  SITEMAPS = [{ ctrl: 'projects', model: Project, priority: 0.8, select: 'id, url_name' },
              { ctrl: 'accounts', model: Account, priority: 0.6, select: 'id, login' }]
  MAX_URLS = 10000

  before_action :setup_sitemap, only: :show

  def index
    @time = Time.now.strftime('%Y-%m-%d')
    @sites = []
    SITEMAPS.each { |type| 1.upto(pages(type[:model])) { |i| @sites << "#{type[:ctrl]}/#{i}.xml" } }
  end

  def show
    @priority = @sitemap[:priority]
    @time = Time.now.strftime('%Y-%m-%d')
    objects = @sitemap[:model].active.select(@sitemap[:select]).offset(offset).limit(MAX_URLS).order(:id)
    @urls = objects.map {|o| url_for(controller: @sitemap[:ctrl], only_path: false, action: 'show', id: o.to_param) }
  end

  protected

  def offset
    (params[:page].to_i - 1) * MAX_URLS
  end

  def pages(model)
    Rational(model.active.length, MAX_URLS).ceil
  end

  def setup_sitemap
    @sitemap = SITEMAPS.find {|s| s[:ctrl] == params[:ctrl]}
    fail ActionController::RoutingError, 'Unsupported sitemap controller' unless @sitemap
  end
end
