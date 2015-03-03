module SearchablesHelper
  def no_search_match(query)
    haml_tag :div, class: 'inset advanced_search_tips' do
      haml_tag :h4, t('searchables.no_match_your_search', query: query)
      haml_tag :p, t('searchables.no_match_suggestions')
      haml_tag :ul do
        haml_tag :li, t('searchables.no_match_make_sure')
        haml_tag :li, t('searchables.no_match_try1')
        haml_tag :li, t('searchables.no_match_try2')
        haml_tag :li, t('searchables.no_match_try3')
      end
    end
  end
end
