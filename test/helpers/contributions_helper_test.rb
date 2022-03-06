# frozen_string_literal: true

require 'test_helper'

class ContributionsHelperTest < ActionView::TestCase
  include ContributionsHelper

  describe 'link_to_claim_position' do
    it 'should return link for claiming position' do
      contribution = create(:person).contributions.first
      _(link_to_claim_position(contribution, 'test').scan(/(test)/)).must_equal [['test']]
      _(link_to_claim_position(contribution, 'test').scan(/(invite)/)).must_equal [['invite']]
      _(link_to_claim_position(contribution, 'test').scan(/(btn-primary)/)).must_equal [['btn-primary']]
      _(link_to_claim_position(contribution, 'test').scan(/(one_click_create)/)).must_equal [['one_click_create']]
    end
  end

  describe 'months_or_years' do
    it 'should return month year string' do
      _(months_or_years(13)).must_equal '1y 1m'
    end

    it 'should return month year string with months alone' do
      _(months_or_years(10)).must_equal '10m'
    end
  end
end
