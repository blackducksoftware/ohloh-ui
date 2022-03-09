# frozen_string_literal: true

require 'test_helper'

class CommitFlag::BackToLifeTest < ActiveSupport::TestCase
  it '#time_elapsed' do
    cf = create(:commit_flag, type: 'CommitFlag::BackToLife', data: { time_elapsed: 789.0 })
    btl = CommitFlag::BackToLife.find(cf.id)
    _(btl.time_elapsed).must_equal 789.0
  end

  it '#time_elapsed=' do
    cf = create(:commit_flag, type: 'CommitFlag::BackToLife')
    btl = CommitFlag::BackToLife.find(cf.id)
    btl.time_elapsed = 123.0
    btl.save!
    _(btl.time_elapsed).must_equal 123.0
  end
end
