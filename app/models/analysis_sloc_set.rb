class AnalysisSlocSet < SecondBase::Base
  belongs_to :analysis
  belongs_to :sloc_set
  has_many :commit_flags, class_name: CommitFlag, foreign_key: :sloc_set_id, primary_key: :sloc_set_id
  has_one :project, primary_key: :analysis_id, foreign_key: :best_analysis_id

  scope :for_code_location, lambda { |code_location_id|
    joins(sloc_set: :code_location).where(code_locations: { id: code_location_id })
  }
  scope :for_analysis, ->(analysis_id) { where(analysis_id: analysis_id) }

  def ignore_tuples
    conditions = ignore_prefixes.collect do |prefix|
      AnalysisSlocSet.sanitize_sql_condition(prefix)
    end.join(' OR ')
    conditions.concat(" and fyles.code_set_id = #{sloc_set.code_set_id}") if conditions.present?
  end

  def ignore_prefixes
    Ignore.parse(ignore).map { |prefix| adjust_leading_slash(prefix) }
  end

  class << self
    def sanitize_sql_condition(file_name)
      sanitize_sql_for_conditions(["fyles.name like '%s%%'", sanitize_sql_like(file_name)])
    end
  end

  private

  def adjust_leading_slash(file_name)
    if sloc_set.code_set.repository.is_a? SvnSyncRepository
      file_name.gsub(/^[^\/]/, '/\0')
    else
      file_name.gsub(/^\//, '')
    end
  end
end
