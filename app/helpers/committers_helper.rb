# frozen_string_literal: true

module CommittersHelper
  def html_title
    if current_user.present? && params[:flow].present?
      I18n.t('committers.user_title', name: current_user.name)
    else
      query = ": #{params[:query]}" if params[:query].present?
      I18n.t('committers.title', text: query)
    end
  end
end
