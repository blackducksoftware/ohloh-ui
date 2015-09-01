require 'test_helper'

class CodeSet::DiffTest < ActiveSupport::TestCase
  describe 'create_all' do
    let(:repository) { create(:svn_repository) }
    let(:code_set) { create(:code_set, repository: repository) }
    let(:commit) { create(:commit, code_set: code_set) }
    let(:scm_commit) do
      OhlohScm::Commit.new(message: Faker::Lorem.sentence, token: Faker::Internet.password,
                           author_name: Faker::Name.name, committer_name: Faker::Name.name,
                           author_email: Faker::Internet.email, committer_email: Faker::Internet.email,
                           author_date: Faker::Time.backward, committer_date: Faker::Time.backward)
    end

    let(:scm_diff) do
      OhlohScm::Diff.new(path: Faker::Internet.url, action: 'D',
                         parent_sha1: Faker::Internet.password, sha1: Faker::Internet.password)
    end

    it 'must create diffs from scm_commit' do
      scm_commit.stubs(:diffs).returns([scm_diff])
      CodeSet::Diff.new(commit, scm_commit, code_set).create_all

      diff = commit.reload.diffs.first
      diff.must_be :deleted
      diff.parent_sha1.must_equal scm_diff.parent_sha1
      diff.sha1.must_equal scm_diff.sha1
    end

    it 'must set parent_sha1 to NULL_SHA1 when it is missing in an additive diff' do
      scm_diff.action = 'A'
      scm_diff.parent_sha1 = nil
      scm_commit.stubs(:diffs).returns([scm_diff])

      CodeSet::Diff.new(commit, scm_commit, code_set).create_all

      diff = commit.reload.diffs.first
      diff.parent_sha1.must_equal NULL_SHA1
    end
  end
end
