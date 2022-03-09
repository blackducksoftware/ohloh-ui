# frozen_string_literal: true

require 'test_helper'

class NilKudoScoreTest < ActiveSupport::TestCase
  let(:nil_kudo_score) { NilKudoScore.new }

  describe 'id' do
    it 'should' do
      _(nil_kudo_score.id).must_be_nil
    end
  end

  describe 'position' do
    it 'should' do
      _(nil_kudo_score.position).must_be_nil
    end
  end

  describe 'score' do
    it 'should' do
      _(nil_kudo_score.score).must_be_nil
    end
  end

  describe 'rank' do
    it 'should' do
      _(nil_kudo_score.rank).must_be_nil
    end
  end

  describe 'nil?' do
    it 'should' do
      _(nil_kudo_score.nil?).must_equal true
    end
  end

  describe 'blank?' do
    it 'should' do
      _(nil_kudo_score.blank?).must_equal true
    end
  end
end
