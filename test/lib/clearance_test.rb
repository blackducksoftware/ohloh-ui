# frozen_string_literal: true

require 'test_helper'

class ClearanceTest < ActiveSupport::TestCase
  describe 'logging in' do
    before do
      @myclass = ClearanceTestModel.new
      @account = create(:account, password: 'mypassword')
    end

    it 'should authenticate by login' do
      _(@myclass.authenticate(login: { login: @account.login, password: 'mypassword' }).id).must_equal @account.id
    end

    it 'should authenticate by email' do
      _(@myclass.authenticate(login: { login: @account.email, password: 'mypassword' }).id).must_equal @account.id
    end
  end
end

class ClearanceTestModel
  include ClearanceSetup
end
