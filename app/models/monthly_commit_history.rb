class MonthlyCommitHistory < ActiveRecord::Base
  belongs_to :analysis
  attr_accessor :ticks, :month, :commits
end
