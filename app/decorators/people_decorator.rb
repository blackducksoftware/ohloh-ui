# frozen_string_literal: true

class PeopleDecorator
  def initialize(people)
    @people = people
  end

  def commits_by_project_map
    name_facts_by_vita = preload_name_facts
    @people.each_with_object({}) do |person, cbp_map|
      vita_id = person.account.best_account_analysis&.id
      sorted_cbp = sorted_commits_for(name_facts_by_vita[vita_id])
      cbp_map[person.account_id] = [sorted_cbp.first(3).map(&:first), sorted_cbp.length - 3]
    end
  end

  private

  def preload_name_facts
    vita_ids = @people.filter_map { |p| p.account.best_account_analysis&.id }
    NameFact.where(vita_id: vita_ids).group_by(&:vita_id)
  end

  def sorted_commits_for(name_facts)
    cbp_data = (name_facts || []).flat_map { |nf| nf.commits_by_project || [] }.compact
    aggregate_commits(cbp_data).sort_by { |_k, v| -v }
  end

  def aggregate_commits(cbp_data)
    cbp_data.map(&:symbolize_keys).each_with_object({}) do |hsh, res|
      pos_id = hsh[:position_id].to_i
      res[pos_id] ||= 0
      res[pos_id] += hsh[:commits].to_i
    end
  end
end
