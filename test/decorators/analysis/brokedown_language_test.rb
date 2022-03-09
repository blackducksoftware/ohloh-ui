# frozen_string_literal: true

require 'test_helper'

class Analysis::BrokedownLanguageTest < ActiveSupport::TestCase
  let(:brokedown_language) do
    Analysis::BrokedownLanguage.new(total_lines: 100, lines: 50, id: 1, name: 'c', nice_name: 'C')
  end

  describe 'percentage' do
    it 'should return percentge' do
      _(brokedown_language.percentage).must_equal 50
    end
  end

  describe 'info' do
    it 'should return percent and color details' do
      _(brokedown_language.info.first).must_equal 1
      _(brokedown_language.info.second).must_equal 'C'
      _(brokedown_language.info.last[:vanity_url]).must_equal 'c'
      _(brokedown_language.info.last[:percent]).must_equal 50
      _(brokedown_language.info.last[:color]).must_equal 'FF8F00'
    end
  end

  describe 'brief_info' do
    it 'should return shortened info' do
      _(brokedown_language.brief_info.first).must_equal 1
      _(brokedown_language.brief_info.second).must_equal 'C'
      _(brokedown_language.brief_info.last[:percent]).must_equal 50
    end
  end

  describe 'low_percentage?' do
    it 'should return false' do
      _(brokedown_language.low_percentage?).must_equal false
    end

    it 'should return true' do
      brokedown_language = Analysis::BrokedownLanguage.new(total_lines: 100, lines: 3, id: 1, name: 'c', nice_name: 'C')
      _(brokedown_language.low_percentage?).must_equal true
    end
  end
end
