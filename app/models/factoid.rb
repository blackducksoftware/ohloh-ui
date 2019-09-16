# frozen_string_literal: true

class Factoid < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :language
  belongs_to :license

  delegate :project, to: :analysis
end
