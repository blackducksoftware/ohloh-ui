class License < ActiveRecord::Base
  acts_as_editable editable_attributes: [:name, :nice_name, :abbreviation, :description, :url],
                   merge_within: 30.minutes

  def allow_undo?(key)
    ![:name, :nice_name].include?(key)
  end
end
