class Link < ActiveRecord::Base
  # TODO: acts_as_editable and acts_as_protected

  def allow_undo?(key)
    ![:title, :url, :link_category_id].include?(key)
  end
end
