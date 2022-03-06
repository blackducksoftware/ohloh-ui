# frozen_string_literal: true

require 'test_helper'

class CheckAvailabilitiesControllerTest < ActionController::TestCase
  describe 'account' do
    it 'should return true when account is present' do
      create(:account, login: 'robin')
      get :account, params: { query: 'RoBiN' }, xhr: true

      _(response.body).must_equal 'true'
    end

    it 'should return false when account is not present' do
      get :account, params: { query: 'test' }, xhr: true

      _(response.body).must_equal 'false'
    end

    it 'should return false when passed no query string' do
      get :account, xhr: true

      _(response.body).must_equal 'false'
    end
  end

  describe 'project' do
    it 'should return true when project is present' do
      create(:project, vanity_url: 'Mario')
      get :project, params: { query: 'maRio' }, xhr: true

      _(response.body).must_equal 'true'
    end

    it 'should return false when project is not present' do
      get :project, params: { query: 'test' }, xhr: true

      _(response.body).must_equal 'false'
    end

    it 'should return false when passed no query string' do
      get :project, xhr: true

      _(response.body).must_equal 'false'
    end
  end

  describe 'organization' do
    it 'should return true when organization is present' do
      create(:organization, vanity_url: 'Mario')
      get :organization, params: { query: 'maRio' }, xhr: true

      _(response.body).must_equal 'true'
    end

    it 'should return false when organization is not present' do
      get :organization, params: { query: 'test' }, xhr: true

      _(response.body).must_equal 'false'
    end

    it 'should return false when passed no query string' do
      get :organization, xhr: true

      _(response.body).must_equal 'false'
    end
  end

  describe 'license' do
    it 'should return true when license is present' do
      create(:license, vanity_url: 'Mario')
      get :license, params: { query: 'maRio' }, xhr: true

      _(response.body).must_equal 'true'
    end

    it 'should return false when license is not present' do
      get :license, params: { query: 'test' }, xhr: true

      _(response.body).must_equal 'false'
    end

    it 'should return false when passed no query string' do
      get :license, xhr: true

      _(response.body).must_equal 'false'
    end

    it 'must return false if license is deleted' do
      license = create(:license)
      license.destroy

      get :license, params: { query: license.vanity_url }, xhr: true

      _(response.body).must_equal 'false'
    end
  end
end
