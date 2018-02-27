class AnalysisSlocSet < FisBase
  belongs_to :analysis
  belongs_to :sloc_set
  has_many :commit_flags, class_name: CommitFlag, foreign_key: :sloc_set_id, primary_key: :sloc_set_id
  has_one :project, primary_key: :analysis_id, foreign_key: :best_analysis_id

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

    # TODO: Remove dependence on code_locations table here.
    def for_code_location(code_location_id)
      joins(sloc_set: :code_set).joins('join code_locations on best_code_set_id = code_sets.id')
                                .where('code_locations.id = ?', code_location_id)
    end
  end

  private

  def adjust_leading_slash(file_name)
    if sloc_set.code_set.code_location.scm_type.to_s =~ /svn/
      file_name.gsub(/^[^\/]/, '/\0')
    else
      file_name.gsub(/^\//, '')
    end
  end
end
