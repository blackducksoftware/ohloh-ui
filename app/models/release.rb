class Release < ActiveRecord::Base
  belongs_to :project_security_set
  has_and_belongs_to_many :vulnerabilities

  scope :sort_by_release_date, ->(order = :desc) { order(released_on: order) }
  scope :select_within_years, lambda { |year|
    where("(released_on::DATE <= NOW()::DATE) AND \
      (released_on::DATE >= (NOW() - '? year'::INTERVAL)::DATE)", year.to_i)
  }

  TIMESPAN = { '1yr' => [1], '3yr' => [3], '5yr' => [5], '10yr' => [10], 'All' => [''] }.freeze

  def self.latest
    sort_by_release_date.first
  end

  def major_version_number
    version.split('.')[0]
  end

  def minor_versions
    project_security_set.matching_releases(major_version_number)
  end
end
