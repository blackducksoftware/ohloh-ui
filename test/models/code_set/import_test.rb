require 'test_helper'

class CodeSet::ImportTest < ActiveSupport::TestCase
  describe 'perform' do
    let(:repository) { create(:git_repository) }
    let(:code_set) { create(:code_set, repository: repository) }
    let(:commit) { create(:commit, code_set: code_set, position: Faker::Number.number(2)) }
    let(:clump) { create(:git_clump, code_set: code_set) }
    let(:scm_commit) do
      OhlohScm::Commit.new(message: Faker::Lorem.sentence, token: Faker::Internet.password,
                           author_name: Faker::Name.name, committer_name: Faker::Name.name,
                           author_email: Faker::Internet.email, committer_email: Faker::Internet.email,
                           author_date: Faker::Time.backward, committer_date: Faker::Time.backward)
    end

    let(:custom_block) { proc {} }

    before do
      clump.scm.expects(:each_commit).yields(scm_commit)
      clump.scm.expects(:commit_count).returns(1)
      CodeSet::CommitFactory.any_instance.expects(:find_or_create).returns(commit)
      CodeSet::Diff.any_instance.expects(:create_all)

      trunk_commit_tokens = [Faker::Internet.password, scm_commit.token, Faker::Internet.password]
      clump.scm.expects(:commit_tokens).returns(trunk_commit_tokens)
    end

    it 'must set code_set.as_of from commit position' do
      CodeSet::Import.new(code_set).perform(&custom_block)

      code_set.reload.as_of.must_equal commit.position
    end

    it 'must set repository.best_code_set_id' do
      repository.reload.best_code_set_id.must_be_nil
      CodeSet::Import.new(code_set).perform(&custom_block)

      repository.reload.best_code_set_id.must_equal code_set.id
    end

    it 'must return a valid list of steps' do
      steps = []
      CodeSet::Import.new(code_set).perform do |step, max_steps|
        steps << [step, max_steps]
      end

      steps.must_equal [[0, 1], [1, 2], [2, 2]]
    end
  end
end
