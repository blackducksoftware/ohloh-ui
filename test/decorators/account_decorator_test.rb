require 'test_helper'

class AccountDecoratorTest < ActiveSupport::TestCase
  before do
    @c = create(:language, name: 'c', nice_name: 'C')
    @cpp = create(:language, name: 'cpp', nice_name: 'C++')
    @js = create(:language, name: 'javascript', nice_name: 'Javascript')
    @java = create(:language, name: 'java', nice_name: 'Java')
  end

  let(:admin) { create(:admin) }
  let(:user) do
    account = create(:account)
    vita = create(:best_vita, account: account)
    create(:vita_fact, vita: vita)
    account.update!(best_vita: vita)
    account
  end

  let(:cbp) do
    [{ 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '6', 'position_id' => '1' },
     { 'month' => Time.parse('2011-01-01 00:00:00'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2012-11-01 00:00:00'), 'commits' => '1', 'position_id' => '1' }]
  end

  let(:symbolized_cbp) do
    [{ month: Time.parse('2010-04-30 20:00:00 -0400'), commits: '1', position_id: '3' },
     { month: Time.parse('2010-04-30 20:00:00 -0400'), commits: '6', position_id: '1' },
     { month: Time.parse('2011-01-01 00:00:00'), commits: '1', position_id: '3' },
     { month: Time.parse('2012-11-01 00:00:00'), commits: '1', position_id: '1' }]
  end

  let(:cbl) do
    [{ 'commits' => 20, 'l_id' => @c.id, 'l_name' => @c.name, 'l_nice_name' => @c.nice_name },
     { 'commits' => 20, 'l_id' => @cpp.id, 'l_name' => @cpp.name, 'l_nice_name' => @cpp.nice_name },
     { 'commits' => 20, 'l_id' => @js.id, 'l_name' => @js.name, 'l_nice_name' => @js.nice_name },
     { 'commits' => 20, 'l_id' => @java.id, 'l_name' => @java.name, 'l_nice_name' => @java.nice_name }]
  end

  let(:symbolized_cbl) do
    [{ commits: 20, l_id: @c.id, l_name: @c.name, l_nice_name: @c.nice_name },
     { commits: 20, l_id: @cpp.id, l_name: @cpp.name, l_nice_name: @cpp.nice_name },
     { commits: 20, l_id: @js.id, l_name: @js.name, l_nice_name: @js.nice_name },
     { commits: 20, l_id: @java.id, l_name: @java.name, l_nice_name: @java.nice_name }]
  end

  let(:sorted_cbl) do
    [['java', { nice_name: 'Java', commits: 20 }],
     ['javascript', { nice_name: 'Javascript', commits: 20 }],
     ['cpp', { nice_name: 'C++', commits: 20 }],
     ['c', { nice_name: 'C', commits: 20 }]]
  end

  let(:sidebars) do
    [
      [
        [:account_summary, 'Account Summary', "/accounts/#{admin.login}"],
        [:stacks, 'Stacks', "/accounts/#{admin.login}/stacks"],
        [:widgets, 'Widgets', "/accounts/#{admin.login}/widgets"]
      ],
      [
        [:contributions, 'Contributions', nil],
        [:positions, 'Contributions', "/accounts/#{admin.login}/positions"],
        [:languages, 'Languages', "/accounts/#{admin.login}/languages"]
      ],
      [
        [:recognition, 'Recognition', nil],
        [:kudos, 'Kudos', "/accounts/#{admin.login}/kudos"]
      ],
      [
        [:usage, 'Usage', nil],
        [:edit_history, 'Website Edits', "/accounts/#{admin.login}/edits"],
        [:posts, 'Posts', "/accounts/#{admin.login}/posts"],
        [:reviews, 'Reviews', "/accounts/#{admin.login}/reviews"]
      ]
    ]
  end

  describe 'symbolized_commits_by_project' do
    it 'must be empty when account has no best_vita' do
      admin.decorate.symbolized_commits_by_project.must_be_empty
    end

    it 'should return commits_by_project with keys as symbols' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      user.decorate.symbolized_commits_by_project.must_equal symbolized_cbp
    end
  end

  describe 'sorted_commits_by_project' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.sorted_commits_by_project.must_be_empty
    end

    it 'should return sorted commits_by_project data' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      user.decorate.sorted_commits_by_project.must_equal [[1, 7], [3, 2]]
    end
  end

  describe 'symbolized_commits_by_language' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.symbolized_commits_by_language.must_be_empty
    end

    it 'should return commits_by_language with keys as symbols' do
      user.best_vita.vita_fact.update(commits_by_language: cbl)
      user.decorate.symbolized_commits_by_language.must_equal symbolized_cbl
    end
  end

  describe 'sorted_commits_by_language' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.sorted_commits_by_language.must_be_empty
    end

    it 'should return sorted commits_by_language data' do
      user.best_vita.vita_fact.update(commits_by_language: cbl)
      user.decorate.sorted_commits_by_language.must_equal sorted_cbl
    end
  end

  describe '#sidebar_for' do
    let(:current_user) { NilAccount.new }

    it 'should return four sections of menu list' do
      admin.decorate.sidebar_for(current_user).length.must_equal 4
    end

    it 'should have three menus in first section' do
      admin.decorate.sidebar_for(current_user).first.length.must_equal 3
      admin.decorate.sidebar_for(current_user).first.must_equal sidebars.first
    end

    it 'should have three menus in second section' do
      admin.decorate.sidebar_for(current_user).second.length.must_equal 3
      admin.decorate.sidebar_for(current_user).second.must_equal sidebars.second
    end

    it 'should have two menus in third section' do
      admin.decorate.sidebar_for(current_user).third.length.must_equal 2
      admin.decorate.sidebar_for(current_user).third.must_equal sidebars.third
    end

    it 'should have 4 menus in fourth sections' do
      admin.decorate.sidebar_for(current_user).fourth.length.must_equal 4
      admin.decorate.sidebar_for(current_user).fourth.must_equal sidebars.fourth
    end
  end

  describe 'vita_status_message' do
    it 'should return ananlyses_scheduled message' do
      create_position(account: admin, name: create(:name))
      admin.decorate.vita_status_message.must_equal I18n.t('accounts.show.analysis_scheduled')
    end

    it 'should return no contributions message' do
      user.decorate.vita_status_message.must_equal I18n.t('accounts.show.no_contributions')
    end

    it 'should return no commits message' do
      position = create_position(account: admin)
      position.update_column(:name_id, nil)
      admin.decorate.vita_status_message.must_equal I18n.t('accounts.show.no_commits')
    end
  end
end
