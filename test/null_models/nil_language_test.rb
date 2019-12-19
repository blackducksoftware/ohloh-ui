# frozen_string_literal: true

require 'test_helper'

class NilLangaugeTest < ActiveSupport::TestCase
  let(:nil_language) { NilLanguage.new }

  describe 'name' do
    it 'name should return empty string' do
      nil_language.name.must_equal ''
    end
  end

  describe 'nice_name' do
    it 'nice_name should return empty string' do
      nil_language.nice_name.must_equal ''
    end
  end
end
