require 'test_helper'

class ContributorsControllerTest < ActionController::TestCase
  # near
  it 'near should display for unlogged in users' do
    login_as nil
    project = create(:project)
    name = create(:name)
    name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:vita).id)
    name_fact.vita.account.update_attributes(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
    create(:position, project: project, name: name, account: name_fact.vita.account)
    get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 2
    must_respond_with :success
    resp = JSON.parse(response.body)
    resp['accounts'].length.must_equal 1
    resp['accounts'][0]['id'].must_equal name_fact.vita.account.id
    resp['accounts'][0]['latitude'].must_equal name_fact.vita.account.latitude.to_s
    resp['accounts'][0]['longitude'].must_equal name_fact.vita.account.longitude.to_s
  end

  it 'near should support zoomed in values' do
    login_as nil
    project = create(:project)
    name = create(:name)
    name_fact = create(:name_fact, analysis: project.best_analysis, name: name, vita_id: create(:vita).id)
    name_fact.vita.account.update_attributes(best_vita_id: name_fact.vita_id, latitude: 30.26, longitude: -97.74)
    create(:position, project: project, name: name, account: name_fact.vita.account)
    get :near, project_id: project.to_param, lat: 25, lng: 12, zoom: 4
    must_respond_with :success
    resp = JSON.parse(response.body)
    resp['accounts'].length.must_equal 1
    resp['accounts'][0]['id'].must_equal name_fact.vita.account.id
    resp['accounts'][0]['latitude'].must_equal name_fact.vita.account.latitude.to_s
    resp['accounts'][0]['longitude'].must_equal name_fact.vita.account.longitude.to_s
  end
end
