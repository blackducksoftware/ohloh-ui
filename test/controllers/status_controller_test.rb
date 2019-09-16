# frozen_string_literal: true

require 'test_helper'

describe 'StatusControllerTest' do
  describe 'age_spark' do
    it 'should return spark image' do
      get :age_spark
      must_respond_with :ok
    end
  end
end
