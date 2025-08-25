# frozen_string_literal: true

class Duplicate < ApplicationRecord # rubocop:disable Metrics/ClassLength
  RESOLVES = %i[stack_entries kudos tags ratings reviews links aliases
                positions project_experiences edits self].freeze
  include DuplicateAssociations

  scope :unresolved, -> { where.not(resolved: true) }

  validate :verify_good_projects
  validate :verify_bad_projects
  validates :comment, length: { maximum: 1000 }, allow_blank: true

  def resolve!(editor_account)
    @editor_account = editor_account
    Duplicate.transaction { RESOLVES.each { |r| send("resolve_#{r}!") } }
  end

  def self.ransackable_attributes(_auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations
  end

  private

  def verify_good_projects
    errors.add :good_project, I18n.t('duplicates.no_self_referential_duplicates') if good_project_id == bad_project_id
    errors.add :good_project, I18n.t('duplicates.no_valid_project') unless good_project_id
    verify_no_dupes_of_dupes
  end

  def verify_no_dupes_of_dupes
    return unless good_project&.is_a_duplicate

    real_good = good_project.is_a_duplicate.good_project
    errors.add :good_project, I18n.t('duplicates.no_dupe_of_dupe', this: good_project.name, that: real_good.name)
  end

  def verify_bad_projects
    errors.add :bad_project, I18n.t('duplicates.no_valid_project') unless bad_project_id
    verify_not_already_reported
  end

  def verify_not_already_reported
    dupe = bad_project.duplicates.unresolved.try(:first) if bad_project
    return unless dupe

    errors.add :bad_project, I18n.t('duplicates.already_reported', this: bad_project.name, that: dupe.bad_project.name)
  end

  def resolve_tags!
    tag_list = "#{good_project.tag_list} #{bad_project.tag_list}".split.uniq.join(' ')
    good_project.update(editor_account: @editor_account, tag_list: tag_list)
  end

  def resolve_ratings!
    bad_project.ratings.each do |rating|
      good_rating = Rating.find_by(account_id: rating.account_id, project_id: good_project_id)
      good_rating ? rating.destroy : rating.update(project_id: good_project_id)
    end
  end

  def resolve_reviews!
    bad_project.reviews.each do |review|
      good_review = Review.find_by(account_id: review.account_id, project_id: good_project_id)
      good_review ? review.destroy : review.update(project_id: good_project_id)
    end
  end

  def resolve_links!
    bad_project.links.each do |link|
      link.editor_account = @editor_account
      good_link = Link.find_by(url: link.url, project_id: good_project_id)
      good_link ? link.destroy : link.update(project_id: good_project_id)
    end
  end

  def resolve_stack_entries!
    bad_project.stack_entries.each do |stack_entry|
      good_stack_entry = StackEntry.find_by(stack_id: stack_entry.stack_id, project_id: good_project_id)
      good_stack_entry ? stack_entry.destroy : stack_entry.update(project_id: good_project_id)
    end
  end

  def resolve_kudos!
    bad_project.kudos.each do |kudo|
      good_kudo = Kudo.find_by(sender_id: kudo.sender_id, project_id: good_project.id, name_id: kudo.name_id)
      good_kudo ? kudo.destroy : kudo.update(project_id: good_project_id)
    end
  end

  def resolve_aliases!
    bad_project.aliases.each do |a|
      a.editor_account = @editor_account
      Alias.create_for_project(@editor_account, good_project, a.commit_name_id, a.preferred_name_id)
      a.destroy
    end
  end

  def resolve_enlistments!
    bad_project.enlistments.each do |e|
      e.editor_account = @editor_account
      e.code_location.create_enlistment_for_project(@editor_account, good_project, e.ignore)
      e.destroy
    end
  end

  def resolve_positions!
    bad_project.positions.each do |position|
      good_position = Position.find_by(account_id: position.account_id, project_id: good_project_id)
      good_position ? position.destroy : position.update(project_id: good_project_id)
    end
  end

  def resolve_project_experiences!
    ProjectExperience.where(project_id: bad_project_id).find_each do |pe|
      good_pe = ProjectExperience.find_by(position: pe.position_id, project_id: good_project.id)
      good_pe ? pe.destroy : pe.update(project_id: good_project_id)
    end
  end

  def resolve_edits!
    Edit.where(target_id: bad_project_id, target_type: 'Project').where("key = 'name' OR key = 'vanity_url'").delete_all
  end

  def resolve_self!
    bad_project.update(name: "Duplicate Project #{id}", vanity_url: '')
    CreateEdit.find_by(target: bad_project).undo!(@editor_account) unless bad_project.deleted?
    update_attribute(:resolved, true)
  end
end
