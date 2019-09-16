# frozen_string_literal: true

class PositionDecorator < Cherry::Decorator
  delegate :account, :project, :contribution, :name_id,
           :description, :title, :organization, :created_at,
           :effective_ongoing?, :effective_stop_date, to: :position

  def analyzed?
    cbp = position.account.decorate.symbolized_commits_by_project.index_by { |c| c[:position_id].to_i }
    cbp[position.id].present?
  end

  # rubocop:disable Metrics/AbcSize
  def affiliation
    return if position.affiliation_type == 'unaffiliated'
    if position.affiliation_type == 'other' && position.organization_name.present?
      return I18n.t('position.affiliated_with', name: position.organization_name)
    end
    return if position.organization.blank?

    I18n.t('position.affiliated_with', name: position.organization)
  end
  # rubocop:enable Metrics/AbcSize

  def name_fact
    return @name_fact if @name_fact

    name_facts_map_key = "#{project.best_analysis_id}_#{name_id}"
    @name_fact = account.position_core.name_facts[name_facts_map_key].try(:first)
  end

  def project_contributor_or_show_path
    return h.project_contributor_path(project, contribution) if project && contribution

    h.account_position_path(account, position)
  end

  def stop_date
    return 'Present' if effective_ongoing?

    effective_stop_date.strftime('%b %Y')
  end

  def commits_compound_spark_path
    h.commits_compound_spark_account_position_path(account_id: position.account_id,
                                                   id: (position.id || 'total'),
                                                   format: :png)
  end

  def new_and_has_null_description_title_and_organization?
    created_at > 1.hour.ago && description.blank? && title.blank? && organization.blank?
  end

  def analyzed_class_name
    analyzed? ? 'one-project data' : 'one-project no_data'
  end
end
