# frozen_string_literal: true

require 'test_helper'

class ColorsHelperTest < ActionView::TestCase
  include ColorsHelper

  describe 'language_color' do
    it 'should return default color when color is not present in list' do
      _(language_color('test')).must_equal 'EEE'
    end

    it 'should return selected color' do
      LANGUAGE_COLORS.each do |name, color|
        _(language_color(name)).must_equal color
      end
    end
  end

  describe 'language_text_color' do
    it 'should return 000 when color is included in list' do
      BLACK_TEXT_LANGUAGES.each do |color|
        _(language_text_color(color)).must_equal '000'
      end
    end

    it 'should return 000 when color is not present in language_color' do
      _(language_text_color('test')).must_equal '000'
    end

    it 'should return FFF when color is not present in BLACK_TEXT_LANGUAGES' do
      _(language_text_color('xslt')).must_equal 'FFF'
    end
  end
end
