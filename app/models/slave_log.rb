# frozen_string_literal: true

class SlaveLog < ApplicationRecord
  INFO = 1
  WARNING = 2

  belongs_to :job, optional: true
  belongs_to :slave, optional: true
end
