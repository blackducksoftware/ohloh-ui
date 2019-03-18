module Position::Validations
  extend ActiveSupport::Concern

  included do
    validates :description, length: { maximum: 500, allow_nil: true }
    validates :title, length: { maximum: 100, allow_nil: true }
    validates :project_id, uniqueness: { scope: :account_id, allow_nil: true }

    validate :project_id_must_exist
    validate :name_fact_existence, if: :committer_name_and_project?
    validate :position_uniqueness, if: :committer_name_and_project?
    validates :committer_name,
              presence: true, unless: -> { name_id || start_date && (stop_date || ongoing) }
    validate :start_date_must_be_in_past, if: :start_date
    validate :stop_date_must_be_in_past, if: :stop_date
    validate :stop_date_must_be_later_than_start_date, if: -> { start_date && stop_date }
  end

  private

  def project_id_must_exist
    errors.add(:project_oss, I18n.t('position.project_id.blank')) unless project_id
  end

  def name_fact_existence
    find_name_fact_from_project_and_comitter_name ||
      errors.add(:committer_name, I18n.t('position.no_name_fact'))
  end

  def position_uniqueness
    name_fact = find_name_fact_from_project_and_comitter_name
    return unless name_fact

    # check for someone already claiming this name
    prior_position = Position.find_by(project_id: project_id, name_id: name_fact.name_id)
    return unless prior_position && prior_position.id != id

    errors.add(:committer_name, I18n.t('position.name_already_claimed', name: prior_position.account.name))
  end

  def start_date_must_be_in_past
    errors.add(:start_date, I18n.t('position.start_date.in_future')) if start_date > Time.current
  end

  def stop_date_must_be_in_past
    errors.add(:stop_date, I18n.t('position.stop_date.in_future')) if stop_date > Time.current
  end

  def stop_date_must_be_later_than_start_date
    errors.add(:stop_date, I18n.t('position.stop_date.earlier')) if start_date > stop_date
  end
end
