module CommittersHelper
  def html_title
    text = params[:query].present? ? ": #{ params[:query] }" : '- Open Hub'
    I18n.t('committers.title', text: text)
  end
end
