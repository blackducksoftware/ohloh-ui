require_relative '../config/environment'

class Repos
  attr_accessor :without_slash, :with_slash

  def initialize(code_locations_change_csv, deletable_repository_ids_file)
    @code_locations_change_csv = code_locations_change_csv
    @deletable_repository_ids_file = deletable_repository_ids_file
  end

  def merge_or_reassign
    merge_or_reassign_enlistments
    merge_or_reassign_code_locations
    reassign_code_locations_to_enlistments
    capture_with_slash_repository_id
  end

  private

  def merge_or_reassign_enlistments
    enlistments_with_slash = with_slash.enlistments.not_deleted
    return unless enlistments_with_slash.exists?

    if without_slash.enlistments.not_deleted.exists?
      enlistments_with_slash.where('project_id in (?)', without_slash.enlistments.not_deleted.pluck(:project_id))
                            .each { |enlistment| enlistment.update_column(:deleted, true) }
    else
      # Bypass enlistment after_save that ensures job.
      enlistments_with_slash.each { |enlistment| enlistment.update_column(:repository_id, without_slash.id) }
    end
  end

  def merge_or_reassign_code_locations
    primary_branch_names = without_slash.code_locations.map(&:module_branch_name)
    common_code_locations = with_slash.code_locations.select { |code_location| primary_branch_names.include?(code_location.module_branch_name) }

    common_code_locations.each do |code_location_with_slash|
      code_location_with_slash.update!(status: 99, bypass_url_validation: true)
      # Update CSV about code_location_with_slash id change.
      new_code_location = without_slash.code_locations.find { |code_location| code_location.module_branch_name == code_location_with_slash.module_branch_name }
      @code_locations_change_csv << [code_location_with_slash.id, new_code_location.id]
    end

    (with_slash.code_locations - common_code_locations).each do |code_location_with_slash|
      code_location_with_slash.update!(repository_id: without_slash.id, bypass_url_validation: true) rescue ActiveRecord::RecordNotUnique
    end
  end

  def reassign_code_locations_to_enlistments
    code_locations_without_slash = without_slash.code_locations
    Enlistment.where('repository_id = ? and code_location_id not in (?)', without_slash.id, code_locations_without_slash.pluck(:id))
              .each do |enlistment|
                associated_branch_name = enlistment.code_location.try(:module_branch_name)
                code_location_id = code_locations_without_slash.find_by(module_branch_name: associated_branch_name).try(:id)
                # Bypass enlistment after_save that ensures job.
                enlistment.update_column(:code_location_id, code_location_id) rescue ActiveRecord::RecordNotUnique
              end
  end

  def capture_with_slash_repository_id
    @deletable_repository_ids_file.puts(with_slash.id)
  end
end


class FixDuplicateRepositories
  def initialize
    fix_duplicates
    close_files
    remove_trailing_backslash_from_repository_urls
  end

  private

  def fix_duplicates
    Repository.find_by_sql("select * from repositories where url in (select left(url, -1) from repositories where right(url, 1) = '/');")
              .each do |repo_without_slash|
      Repository.where(url: repo_without_slash.url + '/').each do |repo_with_slash|
        repos = Repos.new(code_locations_change_csv, deletable_repository_ids_file)
        repos.without_slash = repo_without_slash
        repos.with_slash = repo_with_slash

        if repo_without_slash.enlistments.not_deleted.exists? && repo_with_slash.enlistments.not_deleted.exists?
          repo_without_slash_project_ids = repo_without_slash.enlistments.joins(:project).where('projects.deleted is false').pluck(:project_id)
          repo_project_ids = repo_with_slash.enlistments.joins(:project).where('projects.deleted is false').pluck(:project_id)
          common_project_ids = repo_without_slash_project_ids & repo_project_ids

          # Duplicate repositories are valid across projects. So only check for repositories in the same project.
          repos.merge_or_reassign if common_project_ids.present?
        else
          repos.merge_or_reassign
        end
      end
    end
  end

  def code_locations_change_csv
    @code_locations_change_csv ||= CSV.open("#{ ENV['HOME'] }/OTWO-4905_code_location_id_changes", 'w')
  end

  def deletable_repository_ids_file
    @deletable_repository_ids_file ||= File.open("#{ ENV['HOME'] }/OTWO-4905_deletable_repository_ids", 'w')
  end

  def close_files
    code_locations_change_csv.close
    deletable_repository_ids_file.close
  end

  def remove_trailing_backslash_from_repository_urls
    deletable_repository_ids = File.readlines("#{ ENV['HOME'] }/OTWO-4905_deletable_repository_ids")
    Repository.where("right(url, 1) = '/'").where('id not in (?)', deletable_repository_ids).each do |repository|
      repository.update!(url: repository.url.chomp('/'))
    end
  end
end

FixDuplicateRepositories.new
