class Enlistment < ActiveRecord::Base
  belongs_to :repository
  belongs_to :project

  acts_as_editable editable_attributes: [:ignore]

  class << self
    def add_project_to_repository(editor_account, project, repository, ignore = nil)
      enlistment = Enlistment.where(project_id: project.id, repository_id: repository.id).first_or_initialize
      transaction do
        enlistment.editor_account = editor_account
        enlistment.assign_attributes(ignore: ignore)
        enlistment.save
        CreateEdit.where(target: enlistment).first.redo!(editor_account) if enlistment.deleted
      end
      enlistment.reload
    end
  end
end
