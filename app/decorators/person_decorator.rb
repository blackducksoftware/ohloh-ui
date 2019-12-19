# frozen_string_literal: true

class PersonDecorator < Cherry::Decorator
  def contributions
    object.contributions.includes([{ contributor_fact: :name }, :project]).reject { |contr| contr.project.deleted? }
  end
end
