class PersonDecorator < Cherry::Decorator
  def contributions
    object.contributions.includes([{ contributor_fact: :name }, :project]).select { |contr| !contr.project.deleted? }
  end
end
