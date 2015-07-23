class Clump < ActiveRecord::Base
  belongs_to :code_set

  DIRECTORY = '/var/spool/clumps'

  def scm_class
    OhlohScm::Adapters::GitAdapter
  end

  def path
    return unless code_set_id
    j = code_set_id.to_s.rjust(12, "0")
    "#{ DIRECTORY }/#{ j[0..2] }/#{ j[3..5] }/#{ j[6..8] }/#{ j[9..-1] }"
  end

  def branch_name
    code_set.repository.branch_name
  end

  def scm
    @scm ||= scm_class.new(url: url, branch_name: branch_name).normalize
  end

  # A username and password can be passed in cases where the remote repository
  # requires them (that is, when initializing svnsync against a secured repository).
  def open(opts = {})
    yield self
    # TODO: Consider doing a bare clone for git.
    scm.clean_up_disk if scm.respond_to?(:clean_up_disk)
  end

  def update_fetched_at(newtime)
    update(fetched_at: newtime) unless fetched_at && fetched_at > newtime

    fetched_at
  end
end
