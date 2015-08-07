require 'test_helper'

class CodeSet::CommitFactoryTest < ActiveSupport::TestCase
  describe 'find_or_create' do
    let(:repository) { create(:git_repository) }
    let(:code_set) { create(:code_set, repository: repository) }
    let(:scm_commit) do
      OhlohScm::Commit.new(message: Faker::Lorem.sentence, token: Faker::Internet.password,
                           author_name: Faker::Name.name, committer_name: Faker::Name.name,
                           author_email: Faker::Internet.email, committer_email: Faker::Internet.email,
                           author_date: Faker::Time.backward, committer_date: Faker::Time.backward)
    end

    let(:trunk_commit_tokens) { [Faker::Internet.password, scm_commit.token, Faker::Internet.password] }

    before { create(:git_clump, code_set: code_set) }

    it 'must create a new commit matching scm commit data' do
      commit = CodeSet::CommitFactory.new(code_set, scm_commit, trunk_commit_tokens).find_or_create

      commit.comment.must_equal scm_commit.message
      commit.sha1.must_equal scm_commit.token
      commit.name.name.must_equal scm_commit.author_name
      EmailAddress.find_by(address: scm_commit.author_email).must_be :present?
      commit.time.must_equal scm_commit.author_date
    end

    it 'must update committer information when author information is not found' do
      scm_commit.author_name = nil
      scm_commit.author_date = nil
      scm_commit.author_email = nil

      commit = CodeSet::CommitFactory.new(code_set, scm_commit, trunk_commit_tokens).find_or_create

      commit.name.name.must_equal scm_commit.committer_name
      EmailAddress.find_by(address: scm_commit.committer_email).must_be :present?
      commit.time.must_equal scm_commit.committer_date
    end

    it 'must update a default value when both author and committer names are missing' do
      scm_commit.author_name = nil
      scm_commit.committer_name = nil

      commit = CodeSet::CommitFactory.new(code_set, scm_commit, trunk_commit_tokens).find_or_create

      commit.name.name.must_equal CodeSet::CommitFactory::DEFAULT_NAME
    end

    it 'must update a default value when scm_commit has no message' do
      scm_commit.message = nil

      commit = CodeSet::CommitFactory.new(code_set, scm_commit, trunk_commit_tokens).find_or_create

      commit.comment.must_equal CodeSet::CommitFactory::DEFAULT_COMMIT_COMMENT
    end

    it 'must set on_trunk to true for linear repositories' do
      code_set = create(:code_set, repository: create(:svn_repository))
      commit = CodeSet::CommitFactory.new(code_set, scm_commit, trunk_commit_tokens).find_or_create
      commit.on_trunk.must_equal true
    end

    it 'must set on_trunk to true if commit is on trunk' do
      commit = CodeSet::CommitFactory.new(code_set, scm_commit, trunk_commit_tokens).find_or_create
      commit.on_trunk.must_equal true
    end
  end
end
