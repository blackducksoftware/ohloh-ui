# frozen_string_literal: true

require 'test_helper'

class PositionsControllerTest < ActionController::TestCase
  let(:account) { create(:account) }

  describe 'show' do
    it 'must render successfully if the position is tied to an account lacking a person' do
      create(:position, account: account)
      position = create(:position, account: account)
      position.account.person.delete
      get :show, params: { account_id: account.to_param, id: position.id }

      assert_response :success
      assert_template :show
    end
  end

  describe 'new' do
    it 'must render error for logged out user' do
      get :new, params: { account_id: account.to_param }

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'must render the view successfully' do
      login_as(account)

      get :new, params: { account_id: account.to_param }

      assert_response :success
      assert_template :new
    end
  end

  describe 'create' do
    it 'must render error for logged out user' do
      post :create, params: { account_id: account.to_param }

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'wont allow creating positions for other accounts' do
      login_as(account)
      other_account = create(:account)
      post :create, params: { account_id: other_account.to_param }

      assert_redirected_to new_session_path
    end

    it 'must render errors when validations fail' do
      login_as(account)

      post :create, params: { account_id: account.to_param,
                              position: { project_oss: 'unknown' } }

      assert_template 'new'
      _(response.body).must_match(I18n.t('position.project_id.blank'))
    end

    describe 'success' do
      let(:project) { create(:project) }
      let(:name_obj) { create(:name) }
      before { NameFact.create!(analysis: project.best_analysis, name: name_obj) }

      it 'must respond with a special flash message for invitees' do
        account.update!(created_at: Time.current)
        login_as(account)

        assert_difference 'Position.count', 1 do
          post :create, params: { account_id: account.to_param, invite: true,
                                  position: { project_oss: project.name, committer_name: name_obj.name } }
        end

        assert_redirected_to account_positions_path(account)
        _(flash[:success]).must_equal I18n.t('positions.create.invite_success')
      end

      it 'must create project_experiences' do
        login_as(account)
        project_draper = create(:project, name: :draper)
        project_squeel = create(:project, name: :squeel)

        assert_difference('ProjectExperience.count', 2) do
          post :create, params: { account_id: account.to_param, invite: true,
                                  position: { project_oss: project.name,
                                              committer_name: name_obj.name,
                                              project_experiences_attributes: {
                                                '0' => { project_name: project_squeel.name },
                                                '1' => { project_name: project_draper.name }
                                              } } }
        end

        _(Position.last.project_experiences.map(&:project).map(&:name).sort).must_equal %w[draper squeel]
      end

      it 'must gracefully handle garbage language_exp values' do
        account.update!(created_at: Time.current)
        login_as(account)

        assert_difference 'Position.count', 0 do
          post :create, params: { account_id: account.to_param, invite: true,
                                  position: { project_oss: project.name, committer_name: name_obj.name,
                                              language_exp: ['Esperanto'] } }
        end

        assert_response :unprocessable_entity
        _(response.body).must_match('is invalid')
      end
    end
  end

  describe 'edit' do
    it 'must render successfully' do
      position = create_position(account: account)
      login_as(account)

      get :edit, params: { account_id: account.to_param, id: position.id }

      assert_response :success
      assert_template :edit
    end
  end

  describe 'update' do
    let(:position) { create_position }
    let(:account) { position.account }

    it 'must be successful' do
      project = position.project

      name = create(:name)
      NameFact.create!(analysis: project.best_analysis, name: name)

      login_as(account)

      post :update, params: { account_id: account.to_param, id: position.to_param,
                              position: { title: 'Tsar', project_oss: project.name,
                                          committer_name: name.name } }

      assert_redirected_to account_positions_path(account)
    end

    it 'must fail if name is already claimed by someone else' do
      project = create(:project)

      existing_position = create_position(project: project)
      position = create_position(project: project, account: account)

      login_as(account)

      post :update, params: { account_id: account.to_param, id: position.to_param,
                              position: { title: 'Tsar', project_oss: project.name,
                                          committer_name: existing_position.name_fact.name.name } }

      assert_template 'edit'
      error_message = I18n.t('position.name_already_claimed', name: existing_position.account.name)
      _(assigns('position').errors.messages[:committer_name].first).must_equal error_message
    end

    it 'must not destroy existing position' do
      title = 'some_position'
      Position.any_instance.expects(:destroy).never

      login_as(account)
      post :update, params: { account_id: account.to_param, id: position.to_param,
                              position: { title: title } }

      assert_redirected_to account_positions_path(account)
      _(position.reload.title).must_equal title
    end

    it 'must update language_experiences' do
      language = create(:language)
      _(LanguageExperience.count).must_equal 0

      login_as(account)
      post :update, params: { account_id: account.to_param, id: position.to_param,
                              position: { language_exp: [language.id.to_s] } }

      assert_redirected_to account_positions_path(account)
      position.reload
      _(position.language_experiences.first.language).must_equal language
    end

    it 'must validate project_experiences' do
      login_as(account)
      title = 'some_position'
      project_experiences_attributes = {
        project_experiences_attributes: { '0' => { project_name: 'Invalid' } }
      }

      post :update, params: { account_id: account.to_param, id: position.to_param,
                              position: { title: title }.merge(project_experiences_attributes) }

      assert_template :edit
      error_message = assigns(:position).errors.messages[:'project_experiences.project'].first
      _(error_message).must_equal I18n.t('project_experiences.no_matching_project')

      _(position.reload.title).wont_equal title
      _(position.project_experiences).wont_be :present?
    end

    it 'must update project contributions when position.name_id changes' do
      position = create_position
      account = position.account
      project = position.project

      _(project.contributions.map(&:person).map(&:effective_name)).must_equal [account.person.effective_name]

      login_as(account)

      previous_name = position.name
      new_name = create(:name)
      create(:name_fact, analysis: project.best_analysis, name: new_name)
      create(:person, project: project, name: new_name)
      post :update, params: { account_id: account.to_param, id: position.to_param,
                              position: { project_oss: project.name, committer_name: new_name.name } }

      assert_redirected_to account_positions_path(account)
      _(project.reload.contributions.map(&:person).map(&:effective_name).sort)
        .must_equal [account.person.effective_name, previous_name.name].sort
    end

    describe '_destroy project_experiences' do
      before { login_as(account) }
      let(:project_1) { create(:project) }
      let(:project_2) { create(:project) }
      let(:experience_1) { position.project_experiences.create!(project: project_1) }
      let(:experience_2) { position.project_experiences.create!(project: project_2) }

      it 'must be successful when _destroy has a truthy value' do
        project_experiences_attributes = {
          project_experiences_attributes: {
            '0' => { project_name: project_1.name, id: experience_1.id },
            '1' => { _destroy: '1', id: experience_2.id }
          }
        }

        post :update, params: { account_id: account.to_param, id: position.to_param,
                                position: { title: :something }.merge(project_experiences_attributes) }

        assert_redirected_to account_positions_path(account)
        _(ProjectExperience.find_by(id: experience_2)).must_be_nil
      end

      it 'wont destroy when _destroy has a falsy value' do
        project_experiences_attributes = {
          project_experiences_attributes: {
            '0' => { project_name: project_1.name, id: experience_1.id },
            '1' => { _destroy: 'f', id: experience_2.id }
          }
        }

        post :update, params: { account_id: account.to_param, id: position.to_param,
                                position: { title: :something }.merge(project_experiences_attributes) }

        assert_redirected_to account_positions_path(account)
        _(ProjectExperience.find_by(id: experience_2)).must_be :present?
      end
    end
  end

  describe 'index' do
    let(:account) { create(:account) }

    it 'must render the index page successfully' do
      login_as(account)
      get :index, params: { account_id: account.to_param }

      assert_response :success
    end

    it 'must display the pips' do
      desc = 'Level 3 Describer: edits project descriptions'
      badges = [OpenStruct.new(level: 3, description: desc, levels?: true, level_bits: '0011')]
      Account.any_instance.expects(:badges).returns(badges)
      badge_url = 'https://community.blackduck.com/s/article/Black-Duck-Open-Hub-About-Badges'
      get :index, params: { account_id: account.to_param }
      assert_select 'div.mini-badges-section a.account-badge div.pips.pip-0011'
      assert_select 'div.mini-badges-section a.account-badge[title=?]', desc
      assert_select 'div.mini-badges-section a.account-badge[href=?]', badge_url
    end

    it 'must not display the pips' do
      desc = 'Level 3 Describer: edits project descriptions'
      badges = [OpenStruct.new(level: 3, description: desc, levels?: false, level_bits: '0011')]
      badge_url = 'https://community.blackduck.com/s/article/Black-Duck-Open-Hub-About-Badges'
      Account.any_instance.expects(:badges).returns(badges)

      get :index, params: { account_id: account.to_param }
      assert_select 'div.mini-badges-section a.account-badge div.pips.pip-0011', false
      assert_select 'div.mini-badges-section a.account-badge[title=?]', desc
      assert_select 'div.mini-badges-section a.account-badge[href=?]', badge_url
    end

    it 'must use CommitsByProject to render page successfully' do
      CommitsByProject.any_instance.stubs(:history)
                      .returns(start_date: 7.years.ago.to_date, facts: [], max_commits: 0)
      create_position(account: account)

      get :index, params: { account_id: account.to_param }

      assert_response :success
    end

    it 'must render correctly for an account with no positions' do
      account = create(:account)
      get :index, params: { account_id: account.to_param }

      assert_response :success
      _(response.body).must_match(/There are no contributions available to display/)
    end

    it 'must render correctly for an account with a position but no name_id' do
      position = create_position(account: account)
      position.name_id = nil
      position.save!(validate: false)
      get :index, params: { account_id: account.to_param }

      assert_response :success
      _(response.body).must_match(/There are no commits available to display/)
    end

    it 'must load all positions for a user with graph' do
      account = create(:account)
      position = create_position(account: account)
      get :index, params: { account_id: account.to_param }
      assert_response :success
      language = position.name_fact.primary_language.nice_name
      _(response.body).must_match "1\nCommit\n</a>in mostly\n#{language}"
      _(response.body).must_match position.name_fact.analysis.project.organization.name.gsub("'", '&#39;')
      assert_select 'div#all_projects.chart-with-data[data-value]', 1
    end

    it 'must show project description and title' do
      account = create(:account)
      description = Faker::Lorem.sentence(word_count: 15) # Keep below the 180 character limit
      position = create_position(account: account, description: description)

      get :index, params: { account_id: account.to_param }

      assert_select "span#proj_desc_#{position.id}_lg", description
    end

    it 'must show contribution role and affiliation' do
      position = create_position

      position.update!(title: 'Release Engineer',
                       organization_name: 'Free Software Foundation',
                       description: 'wrote the module for wireless card driver ralink rt5390',
                       affiliation_type: 'other')

      get :index, params: { account_id: position.account.to_param }
      assert_response :success
      assert_select 'span.contribution_role', 'Release Engineer'
      # rubocop:disable Layout/LineLength
      assert_select 'div.one-project-contribution', "Release Engineer\n\nAffiliated with Free Software Foundation\n\nwrote the module for wireless card driver ralink rt5390"
      # rubocop:enable Layout/LineLength
    end

    it 'must show edit link when current user is admin' do
      admin = create(:admin)
      position = create_position
      login_as(admin)

      get :index, params: { account_id: position.account.to_param }

      assert_response :success
      _(response.body).must_match edit_account_position_path(position.account, position)
    end

    it 'must show edit link when viewing own positions' do
      position = create_position
      account = position.account
      login_as(account)

      get :index, params: { account_id: account.to_param }

      assert_response :success
      _(response.body).must_match edit_account_position_path(account, position)
    end

    it 'must show new_position_link when viewing own positions' do
      position = create_position
      login_as(position.account)

      get :index, params: { account_id: position.account.to_param }

      assert_response :success
      _(response.body).must_match new_account_position_path(position.account)
    end

    it 'wont show new_position_link when viewing own positions' do
      position = create_position
      other_account = create(:account)
      login_as(other_account)

      get :index, params: { account_id: position.account.to_param }
      assert_response :success
      _(response.body).wont_match new_account_position_path(position.account)
    end

    it 'must render index in xml format' do
      key = create(:api_key)
      create_position(account: account)

      get :index, params: { account_id: account, format: :xml, api_key: key.oauth_application.uid }

      assert_response :ok
    end

    it 'should have account position url in xml format' do
      key = create(:api_key)
      create_position(account: account)
      Position.any_instance.stubs(:project_id).returns(nil)

      get :index, params: { account_id: account, format: :xml, api_key: key.oauth_application.uid }

      assert_response :ok
    end
  end

  describe 'show' do
    let(:account) { create(:account) }

    it 'must redirect to accounts_language_page when position ID is total' do
      login_as(account)
      get :show, params: { account_id: account.to_param, id: 'total' }

      assert_redirected_to account_languages_path(account)
    end

    it 'wont render the page when ID is not total' do
      position = create_position

      get :show, params: { account_id: position.account.to_param, id: position.id }

      _(assigns('position')).wont_be_nil
      assert_redirected_to project_contributor_path(position.project, position.contribution)
    end

    it 'must render error for a invalid position id' do
      get :show, params: { account_id: account.to_param, id: 0 }
      assert_template 'error.html'
    end
  end

  describe 'commits_compound_spark' do
    it 'should render positions img' do
      position = create_position
      get :commits_compound_spark, params: { account_id: position.account.id, id: position }
      assert_response :ok
    end
  end

  describe 'destroy' do
    it 'must remove positions successfully' do
      position = create_position
      account = position.account

      post :destroy, params: { account_id: account.to_param, id: position.to_param }

      assert_response :redirect
      assert_redirected_to account_positions_path(account)

      account.reload
      _(account.positions.size).must_equal 0
    end
  end

  describe 'one_click_create' do
    it 'must be logged in' do
      get :one_click_create, params: { account_id: account.to_param }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'must raise if project is not found' do
      login_as account
      get :one_click_create, params: { account_id: account.to_param, project_name: 'invalid' }
      assert_response :not_found
    end

    it 'must redirect to claim form if position or alias if not found' do
      login_as account
      project_name = create(:project).name
      committer_name = create(:name).name
      assert_no_difference ['Position.count', 'Alias.count'] do
        get :one_click_create,
            params: { account_id: account.to_param, project_name: project_name, committer_name: committer_name }
      end
      assert_response :redirect
      assert_redirected_to new_account_position_path(account, committer_name: committer_name,
                                                              project_name: project_name)
      _(flash[:success]).must_equal I18n.t('positions.one_click_create.new_position', name: committer_name)
    end

    it 'must create alias if user already has a position' do
      Project.any_instance.stubs(:code_locations).returns([])
      login_as account
      position = create_position(account: account)
      name = create(:person).name.name
      assert_difference 'Alias.count', 1 do
        assert_no_difference 'Position.count' do
          get :one_click_create, params: { account_id: account.to_param, project_name: position.project.name,
                                           committer_name: name }
        end
      end
      assert_response :redirect
      assert_redirected_to account_positions_path(account)
      _(flash[:success]).must_equal I18n.t('positions.one_click_create.alias',
                                           name: name, preferred_name: position.name.name)
    end

    it 'must create position if name is missing' do
      login_as account
      position = create_position(account: account)
      NameFact.find_by(name: position.name).destroy
      name = create(:name)
      create(:name_fact, analysis: position.project.best_analysis, name: name)
      assert_no_difference 'Alias.count' do
        get :one_click_create, params: { account_id: account.to_param, project_name: position.project.name,
                                         committer_name: name.name }
      end
      assert_response :redirect
      assert_redirected_to account_positions_path(account)
      _(flash[:success]).must_equal I18n.t('positions.one_click_create.position', name: name.name)
    end

    it 'should remove contributions record when alias record exists' do
      Project.any_instance.stubs(:code_locations).returns([])
      login_as account
      position = create_position(account: account)
      person = create(:person, project: position.project)
      name = person.name.name
      _(Alias.count).must_equal 0
      get :one_click_create, params: { account_id: account.to_param, project_name: position.project.name,
                                       committer_name: name }
      _(Alias.count).must_equal 1
      new_alias = Alias.first
      new_person = create(:person, project: position.project)
      _(new_person.contributions.reload.count).must_equal 1
      # DON'T KNOW HOW THIS ALIAS IS BEING CREATED IN DB and so we're simulating the same
      create(:alias, commit_name_id: new_person.name_id, project_id: position.project.id,
                     preferred_name_id: new_alias.preferred_name_id)
      get :one_click_create, params: { account_id: account.to_param, project_name: position.project.name,
                                       committer_name: new_person.name.name }
      _(new_person.contributions.reload.count).must_equal 0
    end
  end
end
