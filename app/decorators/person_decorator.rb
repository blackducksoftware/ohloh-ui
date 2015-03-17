class PersonDecorator < Cherry::Decorator
  def contributions
    self.object.contributions.includes([{contributor_fact: :name}, :project])
  end
end
