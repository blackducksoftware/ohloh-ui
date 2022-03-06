# frozen_string_literal: true

require 'test_helper'

class StatusControllerTest < ActionController::TestCase
  describe 'age_spark' do
    it 'should return spark image' do
      get :age_spark
      assert_response :ok
    end
  end
end
