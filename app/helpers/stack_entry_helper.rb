module StackEntryHelper
  def find_stack_entry(stack, project)
    stack.stack_entries.select { |stack_entry| stack_entry.project_id == project.id }
  end
end