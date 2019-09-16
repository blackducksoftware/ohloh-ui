# frozen_string_literal: true

class MonthlyCommitHistory < ActiveRecord::Base
  belongs_to :analysis
  attr_accessor :ticks, :month, :commits
end
