class StackDecorator < Cherry::Decorator
  def name
    return title if respond_to?(:title) && !title.blank?
    return 'Default' if account && self == account.stack_core.default
    return "#{project.name}'s Stack" unless project.nil?
    'Unnamed'
  end
end
