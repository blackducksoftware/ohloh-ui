# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class AccountDecoratorTest < ActiveSupport::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create_account_with_commits_by_project }
  let(:symbolized_cbp) { account.best_account_analysis.account_analysis_fact.commits_by_project.map(&:symbolize_keys) }
  let(:symbolized_cbl) { account.best_account_analysis.account_analysis_fact.commits_by_language.map(&:symbolize_keys) }
  let(:sorted_cbl) { CommitsByLanguageData.sorted }

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
    it 'must be empty when account has no best_account_analysis' do
      _(admin.decorate.symbolized_commits_by_project).must_be_empty
    end

    it 'should return commits_by_project with keys as symbols' do
      _(account.decorate.symbolized_commits_by_project).must_equal symbolized_cbp
    end
  end

  describe 'sorted_commits_by_project' do
    it 'should return [] when account has no best_account_analysis' do
      _(admin.decorate.sorted_commits_by_project).must_be_empty
    end

    it 'should return sorted commits_by_project data' do
      _(account.decorate.sorted_commits_by_project).must_include [account.positions.first.id, 155]
      _(account.decorate.sorted_commits_by_project).must_include [account.positions.last.id, 7]
    end
  end

  describe 'symbolized_commits_by_language' do
    it 'should return [] when account has no best_account_analysis' do
      _(admin.decorate.symbolized_commits_by_language).must_be_empty
    end

    it 'should return commits_by_language with keys as symbols' do
      _(account.decorate.symbolized_commits_by_language).must_equal symbolized_cbl
    end
  end

  describe 'sorted_commits_by_language' do
    it 'should return [] when account has no best_account_analysis' do
      _(admin.decorate.sorted_commits_by_language).must_be_empty
    end

    it 'should return sorted commits_by_language data' do
      _(account.decorate.sorted_commits_by_language).must_equal sorted_cbl
    end
  end

  describe '#sidebar_for' do
    let(:current_account) { NilAccount.new }

    it 'should return four sections of menu list' do
      _(admin.decorate.sidebar_for(current_account).length).must_equal 4
    end

    it 'should have three menus in first section' do
      _(admin.decorate.sidebar_for(current_account).first.length).must_equal 3
      _(admin.decorate.sidebar_for(current_account).first).must_equal sidebars.first
    end

    it 'should have three menus in second section' do
      _(admin.decorate.sidebar_for(current_account).second.length).must_equal 3
      _(admin.decorate.sidebar_for(current_account).second).must_equal sidebars.second
    end

    it 'should have two menus in third section' do
      _(admin.decorate.sidebar_for(current_account).third.length).must_equal 2
      _(admin.decorate.sidebar_for(current_account).third).must_equal sidebars.third
    end

    it 'should have 4 menus in fourth sections' do
      _(admin.decorate.sidebar_for(current_account).fourth.length).must_equal 4
      _(admin.decorate.sidebar_for(current_account).fourth).must_equal sidebars.fourth
    end
  end

  describe 'account_analysis_status_message' do
    it 'should return ananlyses_scheduled message' do
      create_position(account: admin, name: create(:name))
      _(admin.decorate.account_analysis_status_message).must_equal I18n.t('accounts.show.analysis_scheduled')
    end

    it 'should return no contributions message' do
      _(create(:account).decorate.account_analysis_status_message).must_equal I18n.t('accounts.show.no_contributions')
    end

    it 'should return no commits message' do
      position = create_position(account: admin)
      position.update_column(:name_id, nil)
      _(admin.decorate.account_analysis_status_message).must_equal I18n.t('accounts.show.no_commits')
    end
  end
end
