module CommittersHelper
  def html_title
    if current_user.present? && params[:flow].present?
      I18n.t('committers.user_title', name: current_user.name)
    else
      text = params[:query].present? ? ": #{ params[:query] }" : '- Open Hub'
      I18n.t('committers.title', text: text)
    end
  end
end
