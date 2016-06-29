class CodeLocation < ActiveRecord::Base
  STATUS_DELETED   = 0
  STATUS_ACTIVE    = 1
  STATUS_MAP = { STATUS_ACTIVE => :active, STATUS_DELETED => :deleted }.freeze

  belongs_to :repository

  validate :branch_name_pattern

  scope :active, -> { where(status_code: STATUS_ACTIVE) }
  scope :deleted, -> { where(status_code: STATUS_DELETED) }

  def status
    STATUS_MAP[status_code]
  end

  private

  def source_scm
    return @source_scm if @source_scm
    repository.source_scm.send("#{repository.branch_or_module_name}=", branch_name)
    @source_scm = repository.source_scm
  end

  def branch_name_pattern
    normalize_scm_attributes
    source_scm.validate
    populate_scm_errors
  end

  def normalize_scm_attributes
    source_scm.normalize
    self.branch_name = source_scm.branch_name || source_scm.module_name
  end

  def populate_scm_errors
    error_list = source_scm.errors.find { |attribute, _message| %i(branch_name module_name).include?(attribute) }
    errors.add(:branch_name, error_list.last) if error_list.present?
  end
end
