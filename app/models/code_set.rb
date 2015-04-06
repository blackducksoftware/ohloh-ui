class CodeSet < ActiveRecord::Base
  belongs_to :repository
  belongs_to :best_sloc_set, foreign_key: :best_sloc_set_id, class_name: SlocSet
  has_many :commits, -> { order(:position) }, dependent: :destroy
  has_many :fyles, dependent: :delete_all
end
