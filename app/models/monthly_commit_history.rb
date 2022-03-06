# frozen_string_literal: true

class MonthlyCommitHistory < ApplicationRecord
  belongs_to :analysis, optional: true
  attr_accessor :ticks, :month, :commits
end
