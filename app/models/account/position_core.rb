# frozen_string_literal: true

# rubocop: disable InverseOf

class Account::PositionCore < OhDelegator::Base
  parent_scope do
    has_many :positions, lambda {
      positions = Position.arel_table
      projects = Project.arel_table
      joins(positions.join(projects).on(projects[:id].eq(positions[:project_id])
                                    .and(projects[:deleted].eq(false))).join_sources)
    }
    has_many :claimed_positions, -> { where.not(name_id: nil) }, class_name: :Position
  end

  def with_projects
    @with_projects ||=
      positions.joins(:project).where.not(Position.arel_table[:project_id].eq(nil))
               .order(Project.arel_table[:name].lower)
  end

  # rubocop:disable Metrics/AbcSize
  def ordered
    preloaded_positions.sort do |position_a, position_b|
      position_a_name_fact = name_facts["#{position_a.project.best_analysis_id}_#{position_a.name_id}"].try(:first)
      position_b_name_fact = name_facts["#{position_b.project.best_analysis_id}_#{position_b.name_id}"].try(:first)

      if position_a_name_fact && position_b_name_fact
        position_a_name_fact <=> position_b_name_fact
      else
        position_a.project.name.to_s <=> position_b.project.name.to_s
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # Returns a mapping of (position.project.analysis_id)_(position.name_id) => [position.name_fact] for all positions.
  def name_facts
    return @name_facts if @name_facts

    # Using preloaded_positions.pluck(:best_analysis_id) will trigger a new sql query.
    analysis_ids = preloaded_positions.map { |position| position.project.best_analysis_id }.compact
    name_ids = preloaded_positions.map(&:name_id).compact

    name_facts = NameFact.where(analysis_id: analysis_ids, name_id: name_ids)
    @name_facts ||= name_facts.group_by do |name_fact|
      # Form unique groups
      "#{name_fact.analysis_id}_#{name_fact.name_id}"
    end
  end

  # claim a position if there is no existing position for the project or create an alias
  def ensure_position_or_alias!(project, name, try_create = false, position_attributes = {})
    existing_position = project.positions.claimed_by(account).first
    return unless existing_position || try_create

    Account.transaction do
      if existing_position && project.best_analysis.contributor_facts.find_by(name_id: existing_position.name_id)
        create_or_update_alias(project, name, existing_position, position_attributes)
      else
        attributes = position_attributes.merge(account: account, project: project, committer_name: name.name)
        recreate_position(existing_position, attributes)
      end
    end
  end

  def logos
    logo_ids = preloaded_positions.map { |position| position.project.logo_id }.compact
    @logos ||= Logo.find(logo_ids).index_by(&:id)
  end

  class << self
    def with_only_unclaimed
      Account.where('id in (select account_id from positions group by account_id having max(name_id) IS NULL)')
    end
  end

  private

  def create_or_update_alias(project, name, existing_position, position_attributes)
    alias_obj = Alias.find_by(project_id: project.id, commit_name_id: name.id)
    return update_alias(alias_obj, existing_position.name_id, name.id) if alias_obj
    return existing_position if name.id == existing_position.name_id

    create_alias(project, name, existing_position, position_attributes)
  end

  def create_alias(project, name, existing_position, position_attributes)
    # Augment the existing, valid position by creating an alias that merges the old and new names.
    Alias.create(project_id: project.id, commit_name_id: name.id, preferred_name_id: existing_position.name_id,
                 editor_account: account).tap do
      # and update the existing position to use new position_attributes(title, desc)
      existing_position.update!(position_attributes)
    end
  end

  def update_alias(alias_obj, preferred_name_id, commit_name_id)
    if commit_name_id == preferred_name_id
      alias_obj.create_edit.undo!(account) unless alias_obj.deleted?
    else
      alias_obj.create_edit.redo!(account) if alias_obj.deleted? && alias_obj.create_edit.undone?
      alias_obj.reload.update!(preferred_name_id: preferred_name_id, editor_account: account)
    end
  end

  def recreate_position(existing_position, attributes)
    # User may already have a position and its name could be missing (from a deleted CVS repository, probably).
    # In that case, let's delete the existing position, and create a new one.
    existing_position.try(:destroy)
    # If no existing position, then create a new one including the form attributes(title, desc)
    Position.create!(attributes)
  end

  def preloaded_positions
    @preloaded_positions ||= positions.includes({ project: [{ best_analysis: :main_language }, :organization, :logo] },
                                                :name, :account, :contribution, :affiliation)
  end
end

# rubocop: enable InverseOf
