class LanguagesController < ApplicationController
  helper LanguagesHelper
  helper ContributionsHelper

  before_action :tool_context, except: :chart
  before_action :find_language, only: :show

  def index
    @languages = Language.filter_by(params[:query])
                 .send(parse_sort_term)
                 .page(params[:page]).per_page(10)

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def show
    respond_to do |format|
      format.html do
        @language_facts = LanguageFact.where(language_id: @language.id).order(:month)
        @accounts_map = @language.preload_active_and_experienced_accounts
      end
      format.xml
    end
  end

  def chart
    language_data = Language::Chart.new(params).data
    render json: language_data
  end

  def compare
    @measure = params[:measure] || 'commits'
    @language_names = Language.where(name: params[:language_name] || %w(c html java php)).by_name.pluck(:name)
    @languages = Language.by_name.pluck(:nice_name, :name).prepend([t('.none'), '-1'])
  end

  private

  def find_language
    @language = Language.from_param(params[:id]).take
    fail ParamRecordNotFound unless @language
  end

  def parse_sort_term
    Language.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_name'
  end
end
