class HelpfulsController < ApplicationController
  before_action :session_required
  before_action :find_review_and_helpful

  def create
    @helpful.assign_attributes(model_params)
    @helpful.save
    render json: {
      helpful_count_status: render_to_string(partial: 'reviews/helpful_count_status.html.haml',
                                             locals: { review: @review }),
      helpful_yes_or_no_links: render_to_string(partial: 'reviews/helpful_yes_or_no_links.html.haml',
                                                locals: { review: @review })
    }
  end

  private

  def model_params
    params.require(:helpful).permit(:yes)
  end

  def find_review_and_helpful
    @review = Review.find(params[:review_id])
    @helpful = Helpful.where(review_id: params[:review_id], account_id: current_user.id).first_or_initialize
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end
end
