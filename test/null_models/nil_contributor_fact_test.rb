# frozen_string_literal: true

require 'test_helper'

class NilContributorFactTest < ActiveSupport::TestCase
  let(:nil_contributor_fact) { NilContributorFact.new }

  describe 'name_id' do
    it 'should return nil' do
      _(nil_contributor_fact.name_id).must_be_nil
    end
  end

  describe 'primary_language' do
    it 'should return nil' do
      _(nil_contributor_fact.primary_language.is_a?(NilLanguage)).must_equal true
    end
  end

  describe 'name' do
    it 'should return nil' do
      _(nil_contributor_fact.name.is_a?(NilName)).must_equal true
    end
  end

  describe 'first_checkin' do
    it 'should return nil' do
      _(nil_contributor_fact.first_checkin).must_be_nil
    end
  end

  describe 'last_checkin' do
    it 'should return nil' do
      _(nil_contributor_fact.last_checkin).must_be_nil
    end
  end

  describe 'twelve_month_commits' do
    it 'should return zero' do
      _(nil_contributor_fact.twelve_month_commits).must_equal 0
    end
  end

  describe 'commits' do
    it 'should return zero' do
      _(nil_contributor_fact.commits).must_equal 0
    end
  end

  describe 'nil?' do
    it 'should return true' do
      _(nil_contributor_fact.nil?).must_equal true
    end
  end

  describe 'blank?' do
    it 'should return true' do
      _(nil_contributor_fact.blank?).must_equal true
    end
  end

  describe 'present?' do
    it 'should be false' do
      _(nil_contributor_fact.present?).must_equal false
    end
  end

  describe 'name_language_facts' do
    it 'should be empty' do
      _(nil_contributor_fact.name_language_facts).must_equal []
      _(nil_contributor_fact.name_language_facts).must_be_empty
    end
  end
end
