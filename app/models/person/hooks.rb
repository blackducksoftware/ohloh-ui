# frozen_string_literal: true

class Person::Hooks
  def before_validation(person)
    set_id_to_account_id_or_random(person)
    set_name_fact(person) if person.name_id && !person.name_fact_id
    set_effective_name_to_account_or_name(person)
  end

  private

  def set_id_to_account_id_or_random(person)
    person.id ||= person.account_id || ((person.project_id << 32) + person.name_id + 0x80000000)
  end

  def set_effective_name_to_account_or_name(person)
    person.effective_name ||= person.account_id ? person.account.name : person.name.name
  end

  def set_name_fact(person)
    person.name_fact = NameFact.where('name_id = ? and projects.id = ?', person.name_id, person.project_id)
                               .joins(:project).first
  end
end
