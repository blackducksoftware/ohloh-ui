class Link < ActiveRecord::Base
  def allow_undo?(key)
    ![:title, :url, :link_category_id].include?(key)
  end
end
