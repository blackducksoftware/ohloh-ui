# frozen_string_literal: true

require 'test_helper'

describe 'RssArticlesController' do
  describe 'index' do
    it 'must render the page correctly' do
      project = create(:project)

      get :index, project_id: project.to_param

      must_respond_with :success
    end

    it 'must render the page correctly without analysis' do
      project = create(:project)
      Project.any_instance.stubs(:best_analysis).returns(NilAnalysis.new)

      get :index, project_id: project.to_param

      must_respond_with :success
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      project = create(:project)
      login_as account
      project.update!(deleted: true, editor_account: account)

      get :index, project_id: project.to_param

      must_render_template 'deleted'
    end
  end
end
