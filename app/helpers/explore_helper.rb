module ExploreHelper
  def scale_to(count, nearest = 100)
    i = (count/nearest.to_f).ceil
    (i == 0 ? 1 : i)*nearest
  end
end
