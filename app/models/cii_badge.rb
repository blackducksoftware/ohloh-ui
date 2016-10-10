class CiiBadge < ProjectBadge
  validates :url, numericality: { only_integer: true }
end
