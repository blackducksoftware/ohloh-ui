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
  end

  describe 'project' do
    it 'should return true when project is present' do
      create(:project, url_name: 'Mario')
      xhr :get, :project, query: 'maRio'

      response.body.must_equal 'true'
    end

    it 'should return false when project is not present' do
      xhr :get, :project, query: 'test'

      response.body.must_equal 'false'
    end
  end

  describe 'organization' do
    it 'should return true when organization is present' do
      create(:organization, url_name: 'Mario')
      xhr :get, :organization, query: 'maRio'

      response.body.must_equal 'true'
    end

    it 'should return false when organization is not present' do
      xhr :get, :organization, query: 'test'

      response.body.must_equal 'false'
    end
  end

  describe 'license' do
    it 'should return true when license is present' do
      create(:license, name: 'Mario')
      xhr :get, :license, query: 'maRio'

      response.body.must_equal 'true'
    end

    it 'should return false when license is not present' do
      xhr :get, :license, query: 'test'

      response.body.must_equal 'false'
    end
  end
end
