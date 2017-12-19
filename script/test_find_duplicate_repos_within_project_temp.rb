# $ ruby -Itest script/test_find_duplicate_repos_within_project_temp.rb

require_relative '../test/test_helper'

class TestFindDuplicateReposWithinProjectTemp < ActiveSupport::TestCase
  let(:code_location_1) { create(:code_location) }
  let(:code_location_2) { create(:code_location) }
  let(:code_location_3) { create(:code_location) }
  let(:repository_1) { code_location_1.repository }
  let(:repository_2) { code_location_2.repository }
  let(:repository_3) { code_location_3.repository }

  before do
    repository_2.update_column(:url, repository_1.url + '/')
    repository_3.update_column(:url, repository_1.url + '/')
  end

  describe 'enlistments' do
    let(:deletable_repo_ids_file) { "#{ ENV['HOME'] }/OTWO-4905_deletable_repository_ids" }

    before do
      create(:enlistment, code_location: code_location_1)
      create(:enlistment, code_location: code_location_2)
      code_location_3.enlistments.first.update_column(:repository_id, repository_3.id)
    end

    after do
      File.read(deletable_repo_ids_file).to_i.must_equal repository_2.id
    end

    it 'must mark duplicate enlistments within the same project as deleted' do
      enlistment_2 = repository_2.enlistments.first
      enlistment_2.update_column(:project_id, repository_1.enlistments.first.project_id)

      require_relative './find_duplicate_repos_within_project_temp'

      Enlistment.find(enlistment_2.id).must_be :deleted?
      repository_3.enlistments.first.wont_be :deleted?
    end

    it 'must reassign enlistments from duplicate repo when primary repo lacks enlistment' do
      repository_1.enlistments.each(&:delete)
      duplicate_repo_enlistment_ids = repository_2.enlistments.pluck(:id)

      require_relative './find_duplicate_repos_within_project_temp'

      duplicate_repo_enlistment_ids.each do |enlistment_id|
        Enlistment.find_by(id: enlistment_id).repository_id.must_equal repository_1.id
      end
    end

    it 'must mark duplicate repository for deletion if it lacks an enlistment' do
      repository_2.enlistments.each(&:delete)

      require_relative './find_duplicate_repos_within_project_temp'
    end
  end

  describe 'code_locations' do
    let(:code_location_changes_file) { "#{ ENV['HOME'] }/OTWO-4905_code_location_id_changes" }

    it 'must reassign all code locations from duplicate repository' do
      repository_2.enlistments.first.update_column(:project_id, repository_1.enlistments.first.project_id)
      kb_code_location = create(:code_location, repository: repository_2)

      require_relative './find_duplicate_repos_within_project_temp'

      CodeLocation.find(code_location_2.id).repository_id.must_equal repository_1.id
      CodeLocation.find(kb_code_location.id).repository_id.must_equal repository_1.id
    end

    it 'must mark duplicate code locations for deletion' do
      repository_2.enlistments.first.update_column(:project_id, repository_1.enlistments.first.project_id)
      kb_code_location = create(:code_location, repository: repository_2, module_branch_name: code_location_1.module_branch_name)
      code_location_3.update!(module_branch_name: code_location_1.module_branch_name)

      require_relative './find_duplicate_repos_within_project_temp'

      # Reassign non duplicate code location in duplicate repository.
      CodeLocation.find(code_location_2.id).repository_id.must_equal repository_1.id
      CodeLocation.find(code_location_2.id).status.wont_equal 99
      # Mark duplicate code location within same project as deleted.
      CodeLocation.find(kb_code_location.id).repository_id.must_equal repository_2.id
      CodeLocation.find(kb_code_location.id).status.must_equal 99
      File.read(code_location_changes_file).chomp.must_equal "#{ kb_code_location.id },#{ code_location_1.id }"
    end

    it 'must retain duplicate code locations across projects' do
      code_location_3.update!(module_branch_name: code_location_1.module_branch_name)

      require_relative './find_duplicate_repos_within_project_temp'

      CodeLocation.find(code_location_3.id).repository_id.must_equal repository_3.id
      CodeLocation.find(code_location_3.id).status.wont_equal 99
    end
  end

  describe 'reassign_code_locations_to_enlistments' do
    let(:code_location_changes_file) { "#{ ENV['HOME'] }/OTWO-4905_code_location_id_changes" }

    it 'must map enlistment with duplicate code location to original code location' do
      repository_1.enlistments.each(&:delete)
      enlistment_2 = repository_2.enlistments.first
      code_location_2.update!(module_branch_name: code_location_1.module_branch_name)

      require_relative './find_duplicate_repos_within_project_temp'

      CodeLocation.find(code_location_2.id).status.must_equal 99
      Enlistment.find(enlistment_2.id).repository_id.must_equal repository_1.id
      Enlistment.find(enlistment_2.id).code_location_id.must_equal code_location_1.id
      File.read(code_location_changes_file).chomp.must_equal "#{ code_location_2.id },#{ code_location_1.id }"
    end

    it 'must retain enlistments.code_location_id when non duplicate code location' do
      repository_1.enlistments.each(&:delete)
      enlistment_2 = repository_2.enlistments.first

      require_relative './find_duplicate_repos_within_project_temp'

      CodeLocation.find(code_location_2.id).repository_id.must_equal repository_1.id
      Enlistment.find(enlistment_2.id).repository_id.must_equal repository_1.id
      Enlistment.find(enlistment_2.id).code_location_id.must_equal code_location_2.id
    end
  end
end
