require 'test_helper'

class NilVitaFactTest < ActiveSupport::TestCase
  let(:nil_vita_fact) { NilVitaFact.new }

  describe 'first_checkin' do
    it 'should return nil' do
      nil_vita_fact.first_checkin.must_equal nil
    end
  end

  describe 'last_checkin' do
    it 'should return nil' do
      nil_vita_fact.last_checkin.must_equal nil
    end
  end

  describe 'commits' do
    it 'should return zero' do
      nil_vita_fact.commits.must_equal 0
    end
  end

  describe 'commits_by_language' do
    it 'should be empty' do
      nil_vita_fact.commits_by_language.must_equal []
    end
  end

  describe 'commits_by_project' do
    it 'should be empty' do
      nil_vita_fact.commits_by_project.must_equal []
    end
  end

  describe 'nil?' do
    it 'should return true' do
      nil_vita_fact.nil?.must_equal true
    end
  end
end
