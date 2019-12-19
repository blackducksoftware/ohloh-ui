# frozen_string_literal: true

class SitemapController < ApplicationController
  skip_before_action :verify_api_access_for_xml_request

  SITEMAPS = [{ ctrl: 'projects', model: Project, priority: 0.8, select: 'id, vanity_url' },
              { ctrl: 'accounts', model: Account, priority: 0.6, select: 'id, login' }].freeze
  MAX_URLS = 10_000

  before_action :setup_sitemap, only: :show

  def index
    @sites = []
    SITEMAPS.each do |type|
      1.upto(pages(type[:model])) { |i| @sites << "#{type[:ctrl]}/#{i}.xml" }
    end
  end

  def show
    @priority = @sitemap[:priority]
    @objects = @sitemap[:model].active.select(@sitemap[:select]).offset(offset).limit(MAX_URLS).order(:id)
  end

  protected

  def offset
    (page_param - 1) * MAX_URLS
  end

  def pages(model)
    Rational(model.active.count, MAX_URLS).ceil
  end

  def setup_sitemap
    @sitemap = SITEMAPS.find { |s| s[:ctrl] == params[:ctrl] }
    raise ActionController::RoutingError, t('.unsupported') unless @sitemap
  end
end
