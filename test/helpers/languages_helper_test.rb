# frozen_string_literal: true

require 'test_helper'

class LanguagesHelperTest < ActionView::TestCase
  include LanguagesHelper

  describe 'LanguagesHelper TestCase' do
    it 'should match the measures hash' do
      expected_hash = {
        'commits' => I18n.t('languages.monthly_commits'),
        'contributors' => I18n.t('languages.monthly_contributors'),
        'loc_changed' => I18n.t('languages.monthly_loc'),
        'projects' => I18n.t('languages.monthly_projects')
      }
      _(measures).must_equal expected_hash
    end

    it 'should match the measure_description hash' do
      expected_hash = {
        'commits' => I18n.t('languages.commits_desc'),
        'contributors' => I18n.t('languages.contributors_desc'),
        'loc_changed' => I18n.t('languages.loc_desc'),
        'projects' => I18n.t('languages.projects_desc')
      }
      _(measure_description).must_equal expected_hash
    end
  end
end
