class Alias < ActiveRecord::Base
  def allow_undo?(key)
    ![:preferred_name_id].include?(key)
  end
end
