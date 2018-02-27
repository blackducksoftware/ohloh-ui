class CodeLocation < FisbotApi
  include CodeLocationJobs
  extend ActiveModel::Naming # for model_name used by form_for.
  SCM_NAME_DICT = { git: :Git, hg: :Mercurial, cvs: :CVS, bzr: :Bazaar, git_svn: :Subversion,
                    svn: :Subversion, svn_sync: 'Subversion (via SvnSync)' }.freeze

  STATUS_UNDEFINED = 0
  STATUS_ACTIVE  = 1
  STATUS_DELETED = 2

  TRAITS = %w(url scm_type username password branch forge_match best_code_set_id do_not_fetch).freeze
  attr_accessor(*TRAITS)
  attr_reader :to_key # to_key is used by form_for.

  def nice_url
    "#{url} #{branch}"
  end

  def id
    @id.to_i if @id.present?
  end

  def scm_name_in_english
    SCM_NAME_DICT[scm_type.to_sym]
  end

  def failed?
    jobs.order(:current_step_at).reverse.first.try(:failed?)
  end

  def create_enlistment_for_project(editor_account, project, ignore = nil)
    enlistment = Enlistment.where(project_id: project.id, code_location_id: @id).first_or_initialize
    Enlistment.transaction do
      enlistment.editor_account = editor_account
      enlistment.assign_attributes(ignore: ignore)
      enlistment.save
      CreateEdit.find_by(target: enlistment).redo!(editor_account) if enlistment.deleted
    end
    enlistment.reload
  end

  def scm_attributes
    array = TRAITS.map { |trait_name| [trait_name, send(trait_name)] }
    Hash[array]
  end

  def attributes
    return scm_attributes unless @client_relation_id
    scm_attributes.merge(client_relation_id: @client_relation_id)
  end

  def best_code_set
    CodeSet.find_by(id: @best_code_set_id)
  end

  class << self
    def scm_type_count
      uri = api_access.resource_uri(:scm_type_count)
      JSON.parse(Net::HTTP.get(uri))
    end
  end

  private

  def timeout_interval
    ENV['SCM_URL_VALIDATION_TIMEOUT'].to_i
  end

  def save_success?(response)
    # Response can be :conflict, when code_location already exists(for a different project).
    response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPConflict)
  end
end
