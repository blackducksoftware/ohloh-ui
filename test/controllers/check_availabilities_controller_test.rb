# frozen_string_literal: true

require 'test_helper'

describe 'CheckAvailabilitiesController' do
  describe 'account' do
    it 'should return true when account is present' do
      create(:account, login: 'robin')
      xhr :get, :account, query: 'RoBiN'

      response.body.must_equal 'true'
    end

    it 'should return false when account is not present' do
      xhr :get, :account, query: 'test'

      response.body.must_equal 'false'
    end

    it 'should return false when passed no query string' do
      xhr :get, :account

      response.body.must_equal 'false'
    end
  end

  describe 'project' do
    it 'should return true when project is present' do
      create(:project, vanity_url: 'Mario')
      xhr :get, :project, query: 'maRio'

      response.body.must_equal 'true'
    end

    it 'should return false when project is not present' do
      xhr :get, :project, query: 'test'

      response.body.must_equal 'false'
    end

    it 'should return false when passed no query string' do
      xhr :get, :project

      response.body.must_equal 'false'
    end
  end

  describe 'organization' do
    it 'should return true when organization is present' do
      create(:organization, vanity_url: 'Mario')
      xhr :get, :organization, query: 'maRio'

      response.body.must_equal 'true'
    end

    it 'should return false when organization is not present' do
      xhr :get, :organization, query: 'test'

      response.body.must_equal 'false'
    end

    it 'should return false when passed no query string' do
      xhr :get, :organization

      response.body.must_equal 'false'
    end
  end

  describe 'license' do
    it 'should return true when license is present' do
      create(:license, vanity_url: 'Mario')
      xhr :get, :license, query: 'maRio'

      response.body.must_equal 'true'
    end

    it 'should return false when license is not present' do
      xhr :get, :license, query: 'test'

      response.body.must_equal 'false'
    end

    it 'should return false when passed no query string' do
      xhr :get, :license

      response.body.must_equal 'false'
    end

    it 'must return false if license is deleted' do
      license = create(:license)
      license.destroy

      xhr :get, :license, query: license.vanity_url

      response.body.must_equal 'false'
    end
  end
end
