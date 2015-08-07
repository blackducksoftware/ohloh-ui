class Clump < ActiveRecord::Base
  belongs_to :code_set

  DIRECTORY = '/var/spool/clumps'

  def scm_class
    OhlohScm::Adapters::GitAdapter
  end

  def path
    ClumpDirectory.path(code_set_id)
  end

  def branch_name
    code_set.repository.branch_name
  end

  def scm
    @scm ||= scm_class.new(url: path, branch_name: branch_name).normalize
  end

  def open
    yield self
    scm.clean_up_disk if scm.respond_to?(:clean_up_disk)
  end

  def update_fetched_at(newtime)
    update(fetched_at: newtime) unless fetched_at && fetched_at > newtime
  end
end
