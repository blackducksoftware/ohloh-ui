class License < ActiveRecord::Base
  acts_as_editable editable_attributes: [:name, :nice_name, :abbreviation, :description, :url],
                   merge_within: 30.minutes
end
