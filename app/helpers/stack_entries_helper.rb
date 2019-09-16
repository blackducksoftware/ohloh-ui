# frozen_string_literal: true

module StackEntriesHelper
  def check_box_params(checked, stack, project)
    options = { type: 'checkbox', name: 'stacked?', id: "stack_#{project.id}_#{stack.to_param}" }
    options = options.merge(checked: 'checked') if checked
    options
  end
end
