require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  # Destroy commits loaded via fixtures. Remove this line when fixtures are removed.
  before { Commit.destroy_all }
  let(:commit) { create(:commit, sha1: Faker::Number.number(15)) }

  describe '#for_project' do
    it 'should return commits' do
      project = commit.code_set.repository.enlistments.first.project
      commits = Commit.for_project(project)
      commits.count.must_equal 1
      commits.first.must_equal commit
    end
  end

  describe '#for_contributor_fact' do
    it 'should return commits' do
      sloc_set = create(:sloc_set, code_set_id: commit.code_set_id)
      analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_set.id)
      analysis_alias = create(:analysis_alias, commit_name: commit.name, analysis_id: analysis_sloc_set.analysis_id)
      contributor_fact = create(:contributor_fact, analysis_id: analysis_sloc_set.analysis_id,
                                                   name_id: analysis_alias.preferred_name_id)
      commits = Commit.for_contributor_fact(contributor_fact)
      commits.count.must_equal 1
      commits.first.must_equal commit
    end
  end

  describe 'lines_added_and_removed' do
    it 'should return total lines added and removed' do
      sloc_metric = create(:sloc_metric)
      commit = sloc_metric.diff.commit
      sloc_metric.diff.commit.update_attributes(code_set_id: sloc_metric.diff.fyle.code_set_id)
      sloc_metric.sloc_set.update_attributes(code_set_id: sloc_metric.diff.fyle.code_set_id)
      analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_metric.sloc_set_id)
      summary = commit.lines_added_and_removed(analysis_sloc_set.analysis_id)
      summary.count.must_equal 2
      summary.first.must_equal sloc_metric.code_added + sloc_metric.blanks_added + sloc_metric.comments_added
      summary.second.must_equal sloc_metric.code_removed + sloc_metric.blanks_removed + sloc_metric.comments_removed
    end

    it 'should return nil if fyle is ignored' do
      sloc_metric = create(:sloc_metric)
      commit = sloc_metric.diff.commit
      sloc_metric.diff.commit.update_attributes(code_set_id: sloc_metric.diff.fyle.code_set_id)
      sloc_metric.sloc_set.update_attributes(code_set_id: sloc_metric.diff.fyle.code_set_id)
      analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_metric.sloc_set_id,
                                                     ignore: "Disallow: #{sloc_metric.diff.fyle.name}")
      summary = commit.lines_added_and_removed(analysis_sloc_set.analysis_id)
      summary.count.must_equal 2
      summary.first.must_equal 0
      summary.second.must_equal 0
    end
  end

  describe 'nice_id' do
    it 'should return nil if not a git, svn or hg' do
      commit.nice_id.must_equal nil
    end

    it 'should return commit id if SvnSyncRepository' do
      commit.code_set.repository = SvnSyncRepository.new
      commit.nice_id.must_equal commit.sha1.prepend('r')
    end

    it 'should return commit id if GitRepository' do
      commit.code_set.repository = GitRepository.new
      commit.nice_id.must_equal commit.sha1
    end

    it 'should truncate commit if short params' do
      commit.code_set.repository = GitRepository.new
      commit.nice_id(short: true).must_equal commit.sha1.to(7)
    end

    it 'should return commit id if HgRepository' do
      commit.code_set.repository = HgRepository.new
      commit.nice_id.must_equal commit.sha1
    end

    it 'must truncate 12 chars of commit if short params is passed' do
      commit.code_set.repository = HgRepository.new
      commit.nice_id(short: true).must_equal commit.sha1.to(11)
    end
  end
end
