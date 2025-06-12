# frozen_string_literal: true

require 'test_helper'

class CommitsControllerTest < ActionController::TestCase
  before do
    @commit1 = create(:commit, position: 0, comment: 'first commit', time: 1.day.ago)
    @commit2 = create(:commit, position: 1,
                               comment: 'second commit',
                               time: 2.days.ago,
                               code_set_id: @commit1.code_set_id)
    @project = create(:project)
    @name1 = create(:name)
    @name2 = create(:name)
    create(:diff, commit_id: @commit1.id)
    create(:diff, commit_id: @commit2.id)
    sloc_set = create(:sloc_set, code_set_id: @commit1.code_set_id)
    analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_set.id,
                                                   analysis_id: @project.best_analysis_id, as_of: 2)
    analysis_alias = create(:analysis_alias, commit_name: @commit1.name, analysis_id: analysis_sloc_set.analysis_id,
                                             preferred_name_id: @name1.id)
    create(:analysis_alias, commit_name: @commit2.name, analysis_id: analysis_sloc_set.analysis_id,
                            preferred_name_id: @name2.id)
    create(:contributor_fact, analysis_id: analysis_sloc_set.analysis_id,
                              name_id: analysis_alias.preferred_name_id)
    @person1 = create(:person, project_id: @project.id, name_id: @name1.id)
    @person2 = create(:person, project_id: @project.id, name_id: @name2.id)
    commit_contributor = CommitContributor.new(code_set_id: @commit1.code_set_id,
                                               name_id: @commit1.name_id,
                                               analysis_id: @project.best_analysis_id,
                                               contribution_id: @project.contributions.first.id,
                                               person_id: @person1.id)
    CommitContributor.stubs(:includes).returns(stub(where: stub(where: [commit_contributor])))
    CommitContributor.stubs(:where).returns(stub(find_by: commit_contributor))
    Project.any_instance.stubs(:commit_contributors).returns(stub(find_by: commit_contributor))
  end

  describe 'index' do
    it 'should not show permission alert' do
      get :index, params: { project_id: @project.id }
      _(flash.count).must_equal 0
    end

    it 'should not return commits if invalid project id' do
      get :index, params: { project_id: 'I am banana' }
      _(assigns(:commits)).must_be_nil
    end

    it 'shoud render commits from a contribution for a single contributor' do
      Analysis.any_instance.stubs(:oldest_code_set_time).returns(Time.current)
      # commit_ids = create_commits
      unique_contributions = @project.contributions.uniq(&:id)
      contribution_one = unique_contributions[0]
      contribution_two = unique_contributions[1]
      get :index, params: { project_id: @project.id, contributor_id: contribution_one.id }
      assert_response :ok
      _(assigns(:commit_contributor).contribution_id).must_equal contribution_one.id
      _(assigns(:commit_contributor).contribution_id).wont_equal contribution_two.id
    end

    it 'should return commits if valid project' do
      time_now = Time.zone.now
      thirty_days_ago = time_now - 30.days
      @project.best_analysis.update(oldest_code_set_time: time_now)
      get :index, params: { project_id: @project.id, time_span: '30 days' }
      _(assigns(:commits).count).must_equal 2
      _(assigns(:commits).first).must_equal @commit1
      _(assigns(:highlight_from).to_a).must_equal thirty_days_ago.to_a
    end

    it 'should gracefully handle garbage time spans' do
      @project.best_analysis.update(oldest_code_set_time: Time.zone.now)
      get :index, params: { project_id: @project.id, time_span: 'I am a banana' }
      assert_response :ok
    end

    it 'should filter the commits if query param is present' do
      get :index, params: { project_id: @project.id, query: @commit1.comment }
      _(assigns(:commits).count).must_equal 1
      _(assigns(:commits).first).must_equal @commit1
    end

    it 'should return nil if invalid filter param' do
      get :index, params: { project_id: @project.id, query: 'oops invalid' }
      _(assigns(:commits).count).must_equal 0
      _(assigns(:commits)).must_be_empty
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      login_as account
      @project.update!(deleted: true, editor_account: account)

      get :index, params: { project_id: @project.id }

      assert_template 'deleted'
    end

    it 'must render commits within 30 days' do
      Analysis.any_instance.stubs(:oldest_code_set_time).returns(Time.current.beginning_of_day)
      commit_ids = create_commits[0..1]

      get :index, params: { project_id: @project.id, time_span: '30 days' }

      _(assigns(:commits).count).must_equal 4
      _(assigns(:commits).pluck(:id)).must_include commit_ids[0]
      _(assigns(:commits).pluck(:id)).must_include commit_ids[1]
    end

    it 'should render commits within last 12 months' do
      Analysis.any_instance.stubs(:oldest_code_set_time).returns(Time.current)
      commit_ids = create_commits[0..2]

      get :index, params: { project_id: @project.id, time_span: '12 months' }

      _(assigns(:commits).count).must_equal 5
      _(assigns(:commits).ids).must_include commit_ids[0]
      _(assigns(:commits).ids).must_include commit_ids[1]
      _(assigns(:commits).ids).must_include commit_ids[2]
    end

    it 'should show add code_location message when enlistment(s) is empty' do
      Project.any_instance.stubs(:best_analysis).returns(NilAnalysis.new)
      get :index, params: { project_id: @project.id }
      assert_response :ok
      _(response.body).must_match I18n.t('projects.show.no_analysis_summary.message_2')

      _(response.body).wont_match I18n.t('commits.summary.commits_per_month')
      _(response.body).wont_match I18n.t('commits.summary.most_recent_commits')
      _(response.body).wont_match I18n.t('commits.summary.see_all_commits')
    end
  end

  describe 'show' do
    it 'should not show permission alert' do
      get :index, params: { project_id: @project.id }
      _(flash.count).must_equal 0
    end

    it 'should return diffs' do
      CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
      get :show, params: { project_id: @project.id, id: @commit1.id }
      _(assigns(:diffs).count).must_equal 1
      _(assigns(:diffs)).must_equal @commit1.diffs
    end

    it 'should not reutn diffs if invalid commit id' do
      get :show, params: { project_id: @project.id, id: 'I am banana' }
      _(assigns(:diffs)).must_be_nil
    end
  end

  describe 'summary' do
    it 'should return commits' do
      get :summary, params: { project_id: @project.id }
      _(assigns(:commits).count).must_equal 2
      _(assigns(:commits).first).must_equal @commit1
    end

    it 'should show no code_location when enlistment is empty' do
      Project.any_instance.stubs(:best_analysis).returns(NilAnalysis.new)
      get :summary, params: { project_id: @project.id }
      assert_response :ok
      _(response.body).must_match I18n.t('projects.show.no_analysis_summary.message_2')

      _(response.body).wont_match I18n.t('commits.summary.commits_per_month')
      _(response.body).wont_match I18n.t('commits.summary.most_recent_commits')
      _(response.body).wont_match I18n.t('commits.summary.see_all_commits')
    end
  end

  describe 'statistics' do
    it 'should return commit and total lines added and removed' do
      CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
      get :statistics, params: { id: @commit1.id, project_id: @project.id }
      _(assigns(:commit)).must_equal @commit1
      _(assigns(:lines_added)).must_equal 0
      _(assigns(:lines_removed)).must_equal 0
    end
  end

  describe 'events' do
    it 'should not respond to html format' do
      create(:name_fact, analysis: @project.best_analysis, name: @name1)
      get :events, params: { project_id: @project.id, id: @commit1.id, contributor_id: @name1.id }, format: :xml
      _(assigns(:daily_commits).first.time.to_a).must_equal @commit1.time.to_a
      _(assigns(:daily_commits).first.comment).must_equal @commit1.comment
    end
  end

  describe 'event_details' do
    it 'should return commits' do
      create(:name_fact, analysis: @project.best_analysis, name: @name1)
      get :event_details, params: { contributor_id: @name1.id, id: @commit1.id,
                                    project_id: @project.id, time: "commit_#{@commit1.time.to_i}" }
      _(assigns(:commits).count).must_equal 1
      _(assigns(:commits).first).must_equal @commit1
    end
  end

  private

  def create_commits
    commits = []
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 2, name: create(:name),
                               comment: 'third commit', time: 5.days.ago).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 3, name: create(:name),
                               comment: 'fourth commit', time: 7.days.ago).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 4, name: create(:name),
                               comment: 'fifth commit', time: 2.months.ago).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 5, name: create(:name),
                               comment: 'sixth commit', time: 2.years.ago).id
    ass = AnalysisSlocSet.where(sloc_set_id: SlocSet.where(code_set_id: @commit1.code_set_id),
                                analysis_id: @project.best_analysis_id).first
    ass.update!(as_of: 6)
    commits.each do |commit_id|
      commit = Commit.find(commit_id)
      create(:analysis_alias, commit_name: commit.name, analysis_id: ass.analysis_id, preferred_name_id: commit.name.id)
    end
    commits
  end
end
