require 'test_helper'
require 'test_helpers/create_contributions_data'

describe 'CommitsController' do
  before do
    @commit1 = create(:commit, position: 0, comment: 'first commit')
    @commit2 = create(:commit, position: 1, comment: 'second commit', code_set_id: @commit1.code_set_id)
    @project = create(:project)
    @name1 = create(:name)
    @name2 = create(:name)
    create(:diff, commit_id: @commit1.id)
    create(:diff, commit_id: @commit2.id)
    sloc_set = create(:sloc_set, code_set_id: @commit1.code_set_id)
    analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_set.id,
                                                   analysis_id: @project.best_analysis_id, as_of: 2)
    analysis_alias = create(:analysis_alias, commit_name: @commit1.name,
                                             analysis_id: analysis_sloc_set.analysis_id,
                                             preferred_name_id: @name1.id)
    analysis_alias = create(:analysis_alias, commit_name: @commit2.name,
                                             analysis_id: analysis_sloc_set.analysis_id,
                                             preferred_name_id: @name2.id)
    @named_commit = NamedCommit.where(commit_id: @commit1.id).take
    create(:contributor_fact, analysis_id: analysis_sloc_set.analysis_id,
                             name_id: analysis_alias.preferred_name_id)
    @person1 = create(:person, project_id: @project.id, name_id: @name1.id)
    @person2 = create(:person, project_id: @project.id, name_id: @name2.id)
    cfs = ContributorFact.find([@person1.name_fact_id, @person2.name_fact_id])
    cfs.each {|cf| cf.update_attribute(:analysis_id, @project.best_analysis_id) }

  end

  describe 'index' do
    it 'should not show permission alert' do
      get :index, project_id: @project.id
      flash.count.must_equal 0
    end

    it 'should not return commits if invalid project id' do
      get :index, project_id: 'I am banana'
      assigns(:named_commits).must_equal nil
    end

    it 'shoud render commits from a contribution for a single contributor' do
      Analysis.any_instance.stubs(:logged_at).returns(Time.current)
      commit_ids = create_commits_and_named_commits
      named_commits = NamedCommit.where(commit_id: commit_ids[0..1])
      unique_contributions = @project.contributions.uniq { |nc| nc.id }
      contribution_one = unique_contributions[0]
      contribution_two = unique_contributions[1]
      get :index, project_id: @project.id, contributor_id: contribution_one.id
      must_respond_with :ok
      assigns(:named_commits).count.must_equal @project.named_commits.where(contribution_id: contribution_one).count
      assigns(:named_commits).first.contribution_id.must_equal contribution_one.id
      assigns(:named_commits).first.contribution_id.wont_equal contribution_two.id
    end

    it 'should return named commits if valid project' do
      time_now = Time.zone.now
      thirty_days_ago = time_now - 30.days
      @project.best_analysis.update_attributes(logged_at: time_now)
      get :index, project_id: @project.id, time_span: '30 days'
      assigns(:named_commits).count.must_equal 2
      assigns(:named_commits).first.must_equal @named_commit
      assigns(:highlight_from).to_a.must_equal thirty_days_ago.to_a
    end

    it 'should gracefully handle garbage time spans' do
      @project.best_analysis.update_attributes(logged_at: Time.zone.now)
      get :index, project_id: @project.id, time_span: 'I am a banana'
      must_respond_with :ok
    end

    it 'should filter the named commits if query param is present' do
      get :index, project_id: @project.id, query: @commit1.comment
      assigns(:named_commits).count.must_equal 1
      assigns(:named_commits).first.must_equal @named_commit
    end

    it 'should return nil if invalid filter param' do
      get :index, project_id: @project.id, query: 'oops invalid'
      assigns(:named_commits).count.must_equal 0
      assigns(:named_commits).must_be_empty
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      login_as account
      @project.update!(deleted: true, editor_account: account)

      get :index, project_id: @project.id

      must_render_template 'deleted'
    end

    it 'must render commits within 30 days' do
      Analysis.any_instance.stubs(:logged_at).returns(Time.current)
      commit_ids = create_commits_and_named_commits
      named_commits = NamedCommit.where(commit_id: commit_ids[0..1])

      get :index, project_id: @project.id, time_span: '30 days'
      assigns(:named_commits).count.must_equal 4
      assigns(:named_commits).must_include @named_commit
      assigns(:named_commits).must_include named_commits[0]
      assigns(:named_commits).must_include named_commits[1]
    end

    it 'should render commits within last 12 months' do
      Analysis.any_instance.stubs(:logged_at).returns(Time.current)
      commit_ids = create_commits_and_named_commits
      named_commits = NamedCommit.where(commit_id: commit_ids[0..2])

      get :index, project_id: @project.id, time_span: '12 months'

      assigns(:named_commits).count.must_equal 5
      assigns(:named_commits).must_include @named_commit
      assigns(:named_commits).must_include named_commits[0]
      assigns(:named_commits).must_include named_commits[1]
      assigns(:named_commits).must_include named_commits[2]
    end
  end

  describe 'show' do
    it 'should not show permission alert' do
      get :index, project_id: @project.id
      flash.count.must_equal 0
    end

    it 'should return diffs' do
      get :show, project_id: @project.id, id: @named_commit.id
      assigns(:diffs).count.must_equal 1
      assigns(:diffs).must_equal @commit1.diffs
    end

    it 'should not reutn diffs if invalid commit id' do
      get :show, project_id: @project.id, id: 'I am banana'
      assigns(:diffs).must_be_nil
    end
  end

  describe 'summary' do
    it 'should return named_commits' do
      get :summary, project_id: @project.id
      assigns(:named_commits).count.must_equal 2
      assigns(:named_commits).first.must_equal @named_commit
    end
  end

  describe 'statistics' do
    it 'should return commit and total lines added and removed' do
      get :statistics, id: @commit1.id, project_id: @project.id
      assigns(:commit).must_equal @commit1
      assigns(:lines_added).must_equal 0
      assigns(:lines_removed).must_equal 0
    end
  end

  describe 'events' do
    it 'should not respond to html format' do
      binding.pry
      get :events, project_id: @project.id, id: @commit1.id, contributor_id: @name1.id, format: :xml
      assigns(:daily_commits).first.time.to_a.must_equal @commit1.time.to_a
      assigns(:daily_commits).first.comment.must_equal @commit1.comment
    end
  end

  describe 'event_details' do
    it 'should return commits' do
      get :event_details, contributor_id: @name1.id, id: @commit1.id,
                          project_id: @project.id, time: "commit_#{@commit1.time.to_i}"
      assigns(:commits).count.must_equal 2
      assigns(:commits).first.must_equal @commit1
    end
  end

  private

  def create_commits_and_named_commits
    commits = []
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 1, name: @commit1.name,
                               comment: 'second commit', time: Time.current - 1.day).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 2, name: @commit1.name,
                               comment: 'third commit', time: Time.current - 1.day).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 1, name: @commit1.name,
                               comment: 'fourth commit', time: Time.current - 2.months).id
    commits << create(:commit, code_set_id: @commit1.code_set_id, position: 2, name: @commit1.name,
                               comment: 'fifth commit', time: Time.current - 2.years).id
    commits
  end
end
