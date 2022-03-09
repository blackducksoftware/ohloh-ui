# frozen_string_literal: true

require 'test_helper'

class FactoidTest < ActiveSupport::TestCase
  describe 'FactoidActivity' do
    it 'should respond to to_s' do
      [FactoidActivityDecreasing, FactoidActivityIncreasing, FactoidActivityStable].each do |factoid_klass|
        _(factoid_klass.new.to_s).wont_equal ''
      end
    end

    it 'should respond to inline' do
      [FactoidActivityDecreasing, FactoidActivityIncreasing, FactoidActivityStable].each do |factoid_klass|
        _(factoid_klass.new.inline).wont_equal ''
      end
    end

    it 'should respond to category' do
      [FactoidActivityDecreasing, FactoidActivityIncreasing, FactoidActivityStable].each do |factoid_klass|
        _(factoid_klass.new.category).wont_equal nil
      end
    end

    it 'should respond to severity' do
      [FactoidActivityDecreasing, FactoidActivityIncreasing, FactoidActivityStable].each do |factoid_klass|
        _(factoid_klass.severity).wont_equal nil
      end
    end
  end

  describe 'FactoidAge' do
    it 'should respond to to_s' do
      [FactoidAgeEstablished, FactoidAgeOld, FactoidAgeVeryOld, FactoidAgeYoung].each do |factoid_klass|
        _(factoid_klass.new.to_s).wont_equal ''
      end
    end

    it 'should respond to inline' do
      [FactoidAgeEstablished, FactoidAgeOld, FactoidAgeVeryOld, FactoidAgeYoung].each do |factoid_klass|
        _(factoid_klass.new.inline).wont_equal ''
      end
    end

    it 'should respond to category' do
      [FactoidAgeEstablished, FactoidAgeOld, FactoidAgeVeryOld, FactoidAgeYoung].each do |factoid_klass|
        _(factoid_klass.new.category).wont_equal nil
      end
    end

    it 'should respond to severity' do
      [FactoidAgeEstablished, FactoidAgeOld, FactoidAgeVeryOld, FactoidAgeYoung].each do |factoid_klass|
        _(factoid_klass.severity).wont_equal nil
      end
    end
  end

  describe 'FactoidComments' do
    it 'should respond to to_s' do
      [FactoidCommentsAverage, FactoidCommentsHigh, FactoidCommentsLow, FactoidCommentsVeryHigh,
       FactoidCommentsVeryLow].each do |factoid_klass|
        _(factoid_klass.new.to_s).wont_equal ''
      end
    end

    it 'should respond to inline' do
      [FactoidCommentsAverage, FactoidCommentsHigh, FactoidCommentsLow, FactoidCommentsVeryHigh,
       FactoidCommentsVeryLow].each do |factoid_klass|
        _(factoid_klass.new.inline).wont_equal ''
      end
    end

    it 'should respond to category' do
      [FactoidCommentsAverage, FactoidCommentsHigh, FactoidCommentsLow, FactoidCommentsVeryHigh,
       FactoidCommentsVeryLow].each do |factoid_klass|
        _(factoid_klass.new.category).wont_equal nil
      end
    end

    it 'should respond to severity' do
      [FactoidCommentsAverage, FactoidCommentsHigh, FactoidCommentsLow, FactoidCommentsVeryHigh,
       FactoidCommentsVeryLow].each do |factoid_klass|
        _(factoid_klass.severity).wont_equal nil
      end
    end
  end

  describe 'FactoidDistribution' do
    it 'should respond to severity' do
      [FactoidDistributionManyPeople, FactoidDistributionManyPeople].each do |factoid_klass|
        _(factoid_klass.severity).wont_equal nil
      end
    end
  end

  describe 'FactoidStaff' do
    it 'should respond to inline' do
      [FactoidStaffDecreasing, FactoidStaffIncreasing, FactoidStaffStable].each do |factoid_klass|
        _(factoid_klass.new.inline).wont_equal ''
      end
    end

    it 'should respond to category' do
      [FactoidStaffDecreasing, FactoidStaffIncreasing, FactoidStaffStable].each do |factoid_klass|
        _(factoid_klass.new.category).wont_equal nil
      end
    end

    it 'should respond to severity' do
      [FactoidStaffDecreasing, FactoidStaffIncreasing, FactoidStaffStable].each do |factoid_klass|
        _(factoid_klass.severity).wont_equal nil
      end
    end
  end

  describe 'FactoidTeamSize' do
    it 'should respond to to_s' do
      [FactoidTeamSizeAverage, FactoidTeamSizeLarge, FactoidTeamSizeOne,
       FactoidTeamSizeSmall, FactoidTeamSizeVeryLarge, FactoidTeamSizeZero].each do |factoid_klass|
        _(factoid_klass.new.to_s).wont_equal ''
      end
    end

    it 'should respond to inline' do
      [FactoidTeamSizeAverage, FactoidTeamSizeLarge, FactoidTeamSizeOne,
       FactoidTeamSizeSmall, FactoidTeamSizeVeryLarge, FactoidTeamSizeZero].each do |factoid_klass|
        _(factoid_klass.new.inline).wont_equal ''
      end
    end

    it 'should respond to category' do
      [FactoidTeamSizeAverage, FactoidTeamSizeLarge, FactoidTeamSizeOne,
       FactoidTeamSizeSmall, FactoidTeamSizeVeryLarge, FactoidTeamSizeZero].each do |factoid_klass|
        _(factoid_klass.new.category).wont_equal nil
      end
    end

    it 'should respond to severity' do
      [FactoidTeamSizeAverage, FactoidTeamSizeLarge, FactoidTeamSizeOne,
       FactoidTeamSizeSmall, FactoidTeamSizeVeryLarge, FactoidTeamSizeZero].each do |factoid_klass|
        _(factoid_klass.severity).wont_equal nil
      end
    end
  end
end
