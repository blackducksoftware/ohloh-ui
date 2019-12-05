# frozen_string_literal: true

class ProjectParamsBuilder
  attr_accessor :row
  attr_reader :messages, :project

  def initialize(account, *param_hash)
    @row = param_hash
    @editor_account = account
    # FDW: find forge record. #API
    @forge_id = Forge.find_by(name: 'Github').id

    @licenses = {}
  end

  def build_project
    @messages = []
    @kb_project_id = @row.values[0]
    process_row
  end

  private

  def process_row
    add_row_params
    validate_row
    @project = create_project
  end

  def create_project
    params = set_params
    @project = ProjectBuilder.new(@editor_account, params).create
    raise ActiveRecord::RecordNotSaved, project.errors.messages unless @project.errors.messages.empty?

    @messages << "KB project #{@kb_project_id} has been imported to Open Hub as project #{@project.id}"
    @project
  end

  def add_row_params
    @row['forge_id'] = @forge_id
    @row['owner_at_forge'], @row['name_at_forge'] = split_name(@row['owner_name'])
    @row['owner'], @row['project_name'] = set_project_name(@row['owner_name'])
  end

  def split_name(owner_name)
    owner_name.split('/')
  end

  def set_project_name(owner_name)
    owner, project = split_name(owner_name)

    # check if project and owner already exists if it does,
    # a ProjectExistsError will be raised in validate_row method
    return if Project.where(owner_at_forge: owner, name_at_forge: project).exists?

    # if project exists with a different owner set name of project to owner_name
    project = owner_name if Project.exists?(name_at_forge: project)
    [owner, project]
  end

  def validate_row
    raise ProjectParamsError, "kb id:#{@kb_project_id} contains a blank description" if @row['description'].blank?
    raise ProjectExistsError, "kb id:#{@kb_project_id} project already exists"  if @row['owner'].nil?
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  def set_params
    name = @row['project_name']
    url = get_url(@row['owner_name'])

    licenses = get_license_ids(row['simple_form'])
    @messages << "#{@kb_project_id} is missing license information" if licenses.empty?

    { 'name' => name, 'description' => row['description'],
      'vanity_url' => get_vanity_url(name),
      'url' => url, 'download_url' => url, 'forge_id' => @forge_id, 'owner_at_forge' => @row['owner_at_forge'],
      'name_at_forge' => @row['name_at_forge'], 'comments' => 'Created by kb_Ingestion script',
      'managed_by_creator' => '0', 'project_licenses_attributes' => licenses,
      'enlistments_attributes' => { '0' => { 'code_location_attributes' =>
        { 'scm_type' => 'git', 'url' => url, 'branch' => row['module_branch'] } } } }
  end
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

  def get_url(raw_url)
    "https://github.com/#{raw_url}"
  end

  def get_license_ids(license_object)
    license_json = JSON.parse license_object
    license_json['set'].each { |x| x['license_id'] = get_license_id(x['licenseId']) }
                       .map { |x| { 'license_id' => x['license_id'] } unless x['license_id'] == '0' }.compact
  end

  def get_license_id(kb_id)
    license = @licenses[kb_id] || License.find_by(kb_id: kb_id) || NoLicense.new
    @licenses[kb_id] = license
    license.id
  end

  def get_vanity_url(name)
    name.tr('/', '_').tr('.', '_').gsub(/\s/, '-')
  end
end
