require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  # Destroy commits loaded via fixtures. Remove this line when fixtures are removed.
  before { Commit.destroy_all }
  let(:commit) { create(:commit, sha1: Faker::Number.number(15)) }

  describe '#for_project' do
    it 'should return commits' do
      enlistment = create_enlistment_with_code_location
      commit.code_set.update!(code_location_id: enlistment.code_location_id)
      CodeSet.any_instance.stubs(:code_location).returns(CodeLocation.new(id: enlistment.code_location_id))
      project = enlistment.project
      commits = Commit.for_project(project)
      commits.count.must_equal 1
      commits.first.must_equal commit
    end
  end

  describe '#for_contributor_fact' do
    it 'should return commits' do
      sloc_set = create(:sloc_set, code_set_id: commit.code_set_id)
      analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_set.id, as_of: 1)
      analysis_alias = create(:analysis_alias, commit_name: commit.name,
                                               analysis_id: analysis_sloc_set.analysis_id,
                                               preferred_name_id: commit.name_id)
      contributor_fact = create(:contributor_fact, analysis_id: analysis_sloc_set.analysis_id,
                                                   name_id: analysis_alias.preferred_name_id)
      commits = Commit.for_contributor_fact(contributor_fact)
      commits.count.must_equal 1
      commits.first.must_equal commit
    end
  end

  describe 'lines_added_and_removed' do
    it 'should return total lines added and removed' do
      commit, analysis_id, sloc_metric = create_commit

      summary = commit.lines_added_and_removed(analysis_id)
      summary.count.must_equal 2
      summary.first.must_equal sloc_metric.code_added + sloc_metric.blanks_added + sloc_metric.comments_added
      summary.second.must_equal sloc_metric.code_removed + sloc_metric.blanks_removed + sloc_metric.comments_removed
    end

    it 'should return nil if fyle is ignored' do
      enlistment = create_enlistment_with_code_location
      commit.code_set.update!(code_location_id: enlistment.code_location_id)
      CodeSet.any_instance.stubs(:code_location).returns(CodeLocation.new(id: enlistment.code_location_id))

      commit, analysis_id = create_commit(ignore_files: true)
      summary = commit.lines_added_and_removed(analysis_id)
      summary.count.must_equal 2
      summary.first.must_equal 0
      summary.second.must_equal 0
    end
  end

  describe 'nice_id' do
    it 'should return nil if not a git, svn or hg' do
      commit.code_set.code_location = CodeLocation.new(scm_type: :cvs)
      commit.nice_id.must_be_nil
    end

    it 'should return commit id if SvnSyncRepository' do
      commit.code_set.code_location = CodeLocation.new(scm_type: :svn_sync)
      commit.nice_id.must_equal commit.sha1.prepend('r')
    end

    it 'should return commit id if GitRepository' do
      commit.code_set.code_location = CodeLocation.new(scm_type: :git)
      commit.nice_id.must_equal commit.sha1
    end

    it 'should truncate commit if short params' do
      commit.code_set.code_location = CodeLocation.new(scm_type: :git)
      commit.nice_id(short: true).must_equal commit.sha1.to(7)
    end

    it 'should return commit id if HgRepository' do
      commit.code_set.code_location = CodeLocation.new(scm_type: :hg)
      commit.nice_id.must_equal commit.sha1
    end

    it 'must truncate 12 chars of commit if short params is passed' do
      commit.code_set.code_location = CodeLocation.new(scm_type: :hg)
      commit.nice_id(short: true).must_equal commit.sha1.to(11)
    end
  end

  private

  def create_commit(ignore_files: false)
    sloc_set = create(:sloc_set)
    commit = create(:commit, code_set: sloc_set.code_set)
    fyle = create(:fyle, code_set: sloc_set.code_set)
    diff = create(:diff, commit: commit, fyle: fyle)
    sloc_metric = create(:sloc_metric, sloc_set: sloc_set, diff: diff)
    ignore_tuples = "Disallow: #{fyle.name}" if ignore_files
    analysis_sloc_set = create(:analysis_sloc_set, sloc_set: sloc_set, ignore: ignore_tuples)
    [commit, analysis_sloc_set.analysis_id, sloc_metric]
  end
end
