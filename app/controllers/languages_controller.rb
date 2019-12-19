# frozen_string_literal: true

class LanguagesController < ApplicationController
  helper LanguagesHelper
  helper ContributionsHelper

  before_action :tool_context, except: :chart
  before_action :find_language, only: :show
  before_action :find_languages, only: :compare

  def index
    @languages = Language.filter_by(params[:query])
                         .send(parse_sort_term)
                         .page(page_param).per_page(10)
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
    @languages = Language.by_name.map { |l| [l.nice_name, l.name] }.prepend([t('.none'), '-1'])
  end

  private

  def find_language
    @language = Language.from_param(params[:id]).take
    raise ParamRecordNotFound unless @language

    redirect_to language_path(@language) if @language.id.to_s == params[:id]
  end

  def find_languages
    @language_names = Language.where(name: params[:language_name]).by_name.map(&:name)
    @language_names = Language.where(name: Language::DEFAULT_LANGUAGES).by_name.map(&:name) if @language_names.blank?
  end

  def parse_sort_term
    Language.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_nice_name'
  end
end
