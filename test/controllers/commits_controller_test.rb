require 'test_helper'

describe 'CommitsController' do
  before do
    @commit1 = create(:commit, position: 0, comment: 'first commit', time: Time.current - 1.day)
    @commit2 = create(:commit, position: 1,
                               comment: 'second commit',
                               time: Time.current - 2.days,
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
      get :index, project_id: @project.id
      flash.count.must_equal 0
    end

    it 'should not return commits if invalid project id' do
      get :index, project_id: 'I am banana'
      assert_nil assigns(:commits)
    end

    it 'shoud render commits from a contribution for a single contributor' do
      Analysis.any_instance.stubs(:oldest_code_set_time).returns(Time.current)
      # commit_ids = create_commits
      unique_contributions = @project.contributions.uniq(&:id)
      contribution_one = unique_contributions[0]
      contribution_two = unique_contributions[1]
      get :index, project_id: @project.id, contributor_id: contribution_one.id
      must_respond_with :ok
      assigns(:commit_contributor).contribution_id.must_equal contribution_one.id
      assigns(:commit_contributor).contribution_id.wont_equal contribution_two.id
    end

    it 'should return commits if valid project' do
      time_now = Time.zone.now
      thirty_days_ago = time_now - 30.days
      @project.best_analysis.update_attributes(oldest_code_set_time: time_now)
      get :index, project_id: @project.id, time_span: '30 days'
      assigns(:commits).count.must_equal 2
      assigns(:commits).first.must_equal @commit1
      assigns(:highlight_from).to_a.must_equal thirty_days_ago.to_a
    end

    it 'should gracefully handle garbage time spans' do
      @project.best_analysis.update_attributes(oldest_code_set_time: Time.zone.now)
      get :index, project_id: @project.id, time_span: 'I am a banana'
      must_respond_with :ok
    end

    it 'should filter the commits if query param is present' do
      get :index, project_id: @project.id, query: @commit1.comment
      assigns(:commits).count.must_equal 1
      assigns(:commits).first.must_equal @commit1
    end

    it 'should return nil if invalid filter param' do
      get :index, project_id: @project.id, query: 'oops invalid'
      assigns(:commits).count.must_equal 0
      assigns(:commits).must_be_empty
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      login_as account
      @project.update!(deleted: true, editor_account: account)

      get :index, project_id: @project.id

      must_render_template 'deleted'
    end

    it 'must render commits within 30 days' do
      Analysis.any_instance.stubs(:oldest_code_set_time).returns(Time.current.beginning_of_day)
      commit_ids = create_commits[0..1]

      get :index, project_id: @project.id, time_span: '30 days'

      assigns(:commits).count.must_equal 4
      assigns(:commits).pluck(:id).must_include commit_ids[0]
      assigns(:commits).pluck(:id).must_include commit_ids[1]
    end

    it 'should render commits within last 12 months' do
      Analysis.any_instance.stubs(:oldest_code_set_time).returns(Time.current)
      commit_ids = create_commits[0..2]

      get :index, project_id: @project.id, time_span: '12 months'

      assigns(:commits).count.must_equal 5
      assigns(:commits).ids.must_include commit_ids[0]
      assigns(:commits).ids.must_include commit_ids[1]
      assigns(:commits).ids.must_include commit_ids[2]
    end
  end

  describe 'show' do
    it 'should not show permission alert' do
      get :index, project_id: @project.id
      flash.count.must_equal 0
    end

    it 'should return diffs' do
      CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
      get :show, project_id: @project.id, id: @commit1.id
      assigns(:diffs).count.must_equal 1
      assigns(:diffs).must_equal @commit1.diffs
    end

    it 'should not reutn diffs if invalid commit id' do
      get :show, project_id: @project.id, id: 'I am banana'
      assigns(:diffs).must_be_nil
    end
  end

  describe 'summary' do
    it 'should return commits' do
      get :summary, project_id: @project.id
      assigns(:commits).count.must_equal 2
      assigns(:commits).first.must_equal @commit1
    end
  end

  describe 'statistics' do
    it 'should return commit and total lines added and removed' do
      CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
      get :statistics, id: @commit1.id, project_id: @project.id
      assigns(:commit).must_equal @commit1
      assigns(:lines_added).must_equal 0
      assigns(:lines_removed).must_equal 0
    end
  end

  describe 'events' do
    it 'should not respond to html format' do
      create(:name_fact, analysis: @project.best_analysis, name: @name1)
      get :events, project_id: @project.id, id: @commit1.id, contributor_id: @name1.id, format: :xml
      assigns(:daily_commits).first.time.to_a.must_equal @commit1.time.to_a
      assigns(:daily_commits).first.comment.must_equal @commit1.comment
    end
  end

  describe 'event_details' do
    it 'should return commits' do
      create(:name_fact, analysis: @project.best_analysis, name: @name1)
      get :event_details, contributor_id: @name1.id, id: @commit1.id,
                          project_id: @project.id, time: "commit_#{@commit1.time.to_i}"
      assigns(:commits).count.must_equal 1
      assigns(:commits).first.must_equal @commit1
    end
  end

  private

  def create_commits
    commits = []
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 2, name: create(:name),
                               comment: 'third commit', time: Time.current - 5.days).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 3, name: create(:name),
                               comment: 'fourth commit', time: Time.current - 7.days).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 4, name: create(:name),
                               comment: 'fifth commit', time: Time.current - 2.months).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 5, name: create(:name),
                               comment: 'sixth commit', time: Time.current - 2.years).id
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
