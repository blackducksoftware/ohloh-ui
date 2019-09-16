# frozen_string_literal: true

require 'test_helper'

class NilVitaTest < ActiveSupport::TestCase
  let(:nil_vita) { NilVita.new }

  describe 'vita_fact' do
    it 'should be nil_vita_fact' do
      nil_vita.vita_fact.class.must_equal NilVitaFact
    end
  end

  describe 'vita_language_facts' do
    it 'should be empty' do
      nil_vita.vita_language_facts.must_equal []
    end
  end

  describe 'nil' do
    it 'should be true' do
      nil_vita.nil?.must_equal true
    end
  end

  describe 'blank' do
    it 'should be true' do
      nil_vita.blank?.must_equal true
    end
  end
end
