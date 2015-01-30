module StacksHelper
  def stack_edit_in_place
    haml_tag :a, class: 'rest_in_place_helper' do
      concat I18n.t('stacks.edit_in_place')
    end
  end
end
