class StackDecorator < Cherry::Decorator
  def name(account, project)
    return self.object.title unless self.object.title.blank?
    return I18n.t('projects.users.default') if !account.nil? && self.object == account.stack_core.default
    return "#{project.name}'s Stack" unless project.nil?
    "Unnamed"
  end
end
