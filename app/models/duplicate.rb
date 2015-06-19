class Duplicate < ActiveRecord::Base
  RESOLVES = [:stack_entries, :kudos, :tags, :ratings, :reviews, :links, :aliases, :enlistments,
              :positions, :project_experiences, :edits, :self]
  belongs_to :good_project, class_name: 'Project'
  belongs_to :bad_project, class_name: 'Project'
  belongs_to :account

  scope :unresolved, -> { where.not(resolved: true) }

  validate :verify_good_projects
  validate :verify_bad_projects
  validates :comment, length: { maximum: 1000 }, allow_blank: true

  def resolve!(editor_account)
    good_project.editor_account = bad_project.editor_account = editor_account
    Duplicate.transaction { RESOLVES.each { |r| send("resolve_#{r}!") } }
  end

  def switch_good_and_bad!
    self.bad_project_id = good_project_id_was
    self.good_project_id = bad_project_id_was
    save(validate: false)
  end

  private

  def verify_good_projects
    errors.add :good_project, I18n.t('duplicates.no_self_referential_duplicates') if good_project_id == bad_project_id
    errors.add :good_project, I18n.t('duplicates.no_valid_project') unless good_project_id
    verify_no_dupes_of_dupes
  end

  def verify_no_dupes_of_dupes
    return unless good_project && good_project.is_a_duplicate
    real_good = good_project.is_a_duplicate.good_project
    errors.add :good_project, I18n.t('duplicates.no_dupe_of_dupe', this: good_project.name, that: real_good.name)
  end

  def verify_bad_projects
    errors.add :bad_project, I18n.t('duplicates.no_valid_project') unless bad_project_id
    verify_not_already_reported
  end

  def verify_not_already_reported
    return unless bad_project && bad_project.duplicates.unresolved.any?
    dupe = bad_project.duplicates.unresolved.first
    errors.add :bad_project, I18n.t('duplicates.already_reported', this: bad_project.name, that: dupe.bad_project.name)
  end

  def resolve_tags!
    good_project.update_attributes(tag_list: "#{good_project.tag_list} #{bad_project.tag_list}")
  end

  def resolve_ratings!
    bad_project.ratings.each do |rating|
      good_rating = Rating.where(account_id: rating.account_id, project_id: good_project_id).first
      good_rating ? rating.destroy : rating.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_reviews!
    bad_project.reviews.each do |review|
      good_review = Review.where(account_id: review.account_id, project_id: good_project_id).first
      good_review ? review.destroy : review.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_links!
    bad_project.links.each do |link|
      link.editor_account = good_project.editor_account
      good_link = Link.where(url: link.url, project_id: good_project_id).first
      good_link ? link.destroy : link.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_stack_entries!
    bad_project.stack_entries.each do |stack_entry|
      good_stack_entry = StackEntry.where(stack_id: stack_entry.stack_id, project_id: good_project_id).first
      good_stack_entry ? stack_entry.destroy : stack_entry.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_kudos!
    bad_project.kudos.each do |kudo|
      good_kudo = Kudo.where(sender_id: kudo.sender_id, project_id: good_project.id, name_id: kudo.name_id).first
      good_kudo ? kudo.destroy : kudo.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_aliases!
    bad_project.aliases.each do |a|
      a.editor_account = good_project.editor_account
      Alias.create_for_project(bad_project.editor_account, good_project, a.commit_name_id, a.preferred_name_id)
      a.destroy
    end
  end

  def resolve_enlistments!
    bad_project.enlistments.each do |e|
      e.editor_account = good_project.editor_account
      Enlistment.enlist_project_in_repository(bad_project.editor_account, good_project, e.repository, e.ignore)
      e.destroy
    end
  end

  def resolve_positions!
    bad_project.positions.each do |position|
      good_position = Position.where(account_id: position.account_id, project_id: good_project_id).first
      good_position ? position.destroy : position.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_project_experiences!
    ProjectExperience.where(project_id: bad_project_id).each do |pe|
      good_pe = ProjectExperience.where(position: pe.position_id, project_id: good_project.id).first
      good_pe ? pe.destroy : pe.update_attributes(project_id: good_project_id)
    end
  end

  def resolve_edits!
    Edit.where(target_id: bad_project_id, target_type: 'Project').where("key = 'name' OR key = 'url_name'").delete_all
  end

  def resolve_self!
    bad_project.update_attributes(name: "Duplicate Project #{id}", url_name: '')
    CreateEdit.where(target: bad_project).first.undo!(bad_project.editor_account) unless bad_project.deleted?
    update_attributes!(resolved: true)
  end
end
