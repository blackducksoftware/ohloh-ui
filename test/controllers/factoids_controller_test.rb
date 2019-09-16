# frozen_string_literal: true

require 'test_helper'

describe 'FactoidsControllerTest' do
  before do
    @factoid = create(:factoid)
    @factoid.analysis.project.update(best_analysis: @factoid.analysis)
    @factoid.analysis.update(headcount: 0)
  end

  describe 'index' do
    it 'should render all the factoids for a project' do
      get :index, project_id: @factoid.analysis.project.to_param
      must_respond_with :success
      response.body.must_match 'Over 75% of all projects on Open Hub have no recent activity.'
    end

    it 'should support being queried via the api' do
      get :index, project_id: @factoid.analysis.project.to_param, format: :xml,
                  api_key: create(:api_key).oauth_application.uid
      must_respond_with :success
      response.body.must_match '<items_returned>1</items_returned>'
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      project = @factoid.analysis.project
      project.update!(deleted: true, editor_account: account)

      get :index, project_id: project.to_param

      must_render_template 'deleted'
    end
  end
end
