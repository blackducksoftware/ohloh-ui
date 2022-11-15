# frozen_string_literal: true

require 'test_helper'

class ComparesControllerTest < ActionDispatch::IntegrationTest
  # projects
  test 'should render with no projects passed in' do
    get compare_projects_url
    assert_response :success
    assert_select 'input#project_0', 1
    assert_select 'input#project_1', 1
    assert_select 'input#project_2', 1
  end

  test 'should render projects when names are supplied in a case insensitive manner' do
    create(:project, name: 'Ruby')
    create(:project, name: 'Java')
    get compare_projects_url, params: { project_0: 'java', project_1: 'rUby' }
    assert_response :success
    _(response.body).must_match 'Java'
    _(response.body).must_match 'Ruby'
  end

  test 'should render up to three projects' do
    project1 = create(:project, name: 'Phil')
    project2 = create(:project, name: 'Jerry')
    project3 = create(:project, name: 'Bob')
    get compare_projects_url, params: { project_0: project1.name, project_1: project2.name, project_2: project3.name }
    assert_response :success
    assert_select 'input#project_0', 0
    assert_select 'input#project_1', 0
    assert_select 'input#project_2', 0
    _(response.body).must_match 'Phil'
    _(response.body).must_match 'Jerry'
    _(response.body).must_match 'Bob'
  end

  test 'should handle some nil projects' do
    project1 = create(:project, name: 'Phil')
    project3 = create(:project, name: 'Bob')
    get compare_projects_url, params: { project_0: project1.name, project_2: project3.name }
    assert_response :success
    assert_select 'input#project_0', 0
    assert_select 'input#project_1', 1
    assert_select 'input#project_2', 0
    _(response.body).must_match 'Phil'
    _(response.body).must_match 'Bob'
  end

  test 'should not fail if project doesnot have analysis' do
    project1 = create(:project, name: 'The Avenger Initiative')
    project1.update!(best_analysis_id: nil)
    get compare_graph_projects_url, params: { metric: 'commit', project_0: project1.name, project_1: 'invalid' },
                                    xhr: true
    assert_response :ok
  end

  test 'should get projects graph route for contributor history' do
    project1 = create(:project, name: 'The Avenger Initiative')
    project2 = create(:project, name: 'X-MEN')
    project3 = create(:project, name: 'Suicide Squad')
    get compare_graph_projects_url,
        params: { metric: 'contributor', project_0: project1.name, project_1: project2.name,
                  project_2: project3.name },
        xhr: true
    assert_response :ok
  end

  test 'should get projects graph route for commit history' do
    project1 = create(:project, name: 'The Avenger Initiative')
    project2 = create(:project, name: 'X-MEN')
    project3 = create(:project, name: 'Suicide Squad')
    get compare_graph_projects_url,
        params: { metric: 'commit', project_0: project1.name, project_1: project2.name, project_2: project3.name },
        xhr: true
    assert_response :ok
  end

  test 'should get projects graph route for code total history' do
    project1 = create(:project, name: 'The Avenger Initiative')
    project2 = create(:project, name: 'X-MEN')
    project3 = create(:project, name: 'Suicide Squad')
    Analysis.any_instance.stubs(:code_total_history).returns([{ 'code_total' => 5 }])
    get compare_graph_projects_url,
        params: { metric: 'code_total', project_0: project1.name, project_1: project2.name, project_2: project3.name },
        xhr: true
    assert_response :ok
  end

  # projects - csv format
  test 'csv format should render with no projects passed in' do
    get compare_projects_url, params: { format: :csv }
    assert_response :success
  end

  test 'csv format should render up to three projects' do
    project1 = create(:project, name: 'Phil')
    project2 = create(:project, name: 'Jerry')
    project3 = create(:project, name: 'Bob')
    get compare_projects_url,
        params: { project_0: project1.name, project_1: project2.name, project_2: project3.name, format: :csv }

    assert_response :success
    _(response.body).must_match 'Phil'
    _(response.body).must_match 'Jerry'
    _(response.body).must_match 'Bob'
  end

  test 'csv format should handle some nil projects' do
    project1 = create(:project, name: 'Phil')
    project3 = create(:project, name: 'Bob')
    project3.best_analysis.update(last_commit_time: nil)
    get compare_projects_url, params: { project_0: project1.name, project_2: project3.name, format: :csv }
    assert_response :success
    _(response.body).must_match 'Phil'
    _(response.body).must_match 'Bob'
  end

  test 'csv format should render a plethora of conceivable project states' do
    project1 = create(:project, name: 'Phil')
    manager = create(:account, name: 'Larry')
    create(:manage, account: manager, target: project1)
    license = create(:license, vanity_url: 'Peter')
    create(:project_license, project: project1, license: license)
    create(:factoid, analysis: project1.best_analysis, type: 'FactoidActivityIncreasing')
    project2 = create(:project, name: 'Jerry')
    project2.best_analysis.update(relative_comments: 4.7)
    create(:factoid, analysis: project2.best_analysis, type: 'FactoidActivityDecreasing')
    project3 = create(:project, name: 'Bob')
    create(:factoid, analysis: project3.best_analysis, type: 'FactoidCommentsHigh')
    create(:factoid, analysis: project3.best_analysis, type: 'FactoidTeamSizeZero')
    project3.best_analysis.update(relative_comments: 7.2)
    get compare_projects_url,
        params: { project_0: project1.name, project_1: project2.name, project_2: project3.name, format: :csv }
    assert_response :success
    _(response.body).must_match 'Phil'
    _(response.body).must_match 'Larry'
    _(response.body).must_match 'Peter'
    _(response.body).must_match 'Jerry'
    _(response.body).must_match 'Bob'
  end

  test 'ThirtyDaySummary commits count when nil, negative and positive values' do
    project1 = create(:project, name: 'Phil')
    project2 = create(:project, name: 'Jerry')
    project3 = create(:project, name: 'Bob')
    commiters_count = 40
    project1.best_analysis.thirty_day_summary.destroy # would return nil
    project2.best_analysis.thirty_day_summary.update(outside_committers_count: -20)
    project3.best_analysis.thirty_day_summary.update(outside_committers_count: commiters_count)
    project1.reload

    tds1 = CompareProjectCsvDecorator.new(project1, host).contributors_last_thirty_days
    _(tds1).must_match I18n.t('compares.no_data')
    tds2 = CompareProjectCsvDecorator.new(project2, host).contributors_last_thirty_days
    _(tds2).must_match I18n.t('compares.no_activity')
    tds3 = CompareProjectCsvDecorator.new(project3, host).contributors_last_thirty_days
    _(tds3).must_match "#{commiters_count} developers"
  end
end
