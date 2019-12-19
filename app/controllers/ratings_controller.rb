# frozen_string_literal: true

class RatingsController < ApplicationController
  helper :projects

  ALLOWED_PARTIALS = ['projects/show/community_rating', 'reviews/rater'].freeze

  before_action :session_required, :redirect_unverified_account
  before_action :set_project_or_fail
  before_action :set_rating

  def rate
    @rating.assign_attributes(model_params)
    @rating.save
    sanitize_partial(params[:show])
    render partial: @partial, locals: { score: @rating.score, project: @project.reload }
  end

  def unrate
    @rating.destroy if @rating.persisted?
    @rating = nil if @rating.destroyed?
    sanitize_partial(params[:show])
    render partial: @partial, locals: { score: '0' }
  end

  private

  def model_params
    params.permit(:score)
  end

  def set_rating
    @rating = Rating.where(project_id: @project.id, account_id: current_user.id).first_or_initialize
  end

  def sanitize_partial(partial)
    return @partial = partial if ALLOWED_PARTIALS.include? partial

    raise StandardError, I18n.t('ratings.partial_not_found', partial: partial)
  end
end
