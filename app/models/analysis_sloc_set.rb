class AnalysisSlocSet < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :sloc_set
end
