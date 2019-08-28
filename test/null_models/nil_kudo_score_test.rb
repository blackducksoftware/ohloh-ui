# frozen_string_literal: true

require 'test_helper'

class NilKudoScoreTest < ActiveSupport::TestCase
  let(:nil_kudo_score) { NilKudoScore.new }

  describe 'id' do
    it 'should' do
      assert_nil nil_kudo_score.id
    end
  end

  describe 'position' do
    it 'should' do
      assert_nil nil_kudo_score.position
    end
  end

  describe 'score' do
    it 'should' do
      assert_nil nil_kudo_score.score
    end
  end

  describe 'rank' do
    it 'should' do
      assert_nil nil_kudo_score.rank
    end
  end

  describe 'nil?' do
    it 'should' do
      nil_kudo_score.nil?.must_equal true
    end
  end

  describe 'blank?' do
    it 'should' do
      nil_kudo_score.blank?.must_equal true
    end
  end
end
