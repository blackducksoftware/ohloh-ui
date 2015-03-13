class CodeSet < ActiveRecord::Base
  belongs_to :repository
  has_many :commits, -> { order(:position) }, dependent: :destroy
end
