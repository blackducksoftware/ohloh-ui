# frozen_string_literal: true

require 'test_helper'

describe 'OhAdmin::AccountsController' do
  let(:admin) { create(:admin) }
  before do
    login_as admin
  end

  describe '#charts' do
    it 'should render index template' do
      [3, 6, 12].each do |period|
        get :charts, period: period
        must_respond_with :ok
      end
    end
  end
end
