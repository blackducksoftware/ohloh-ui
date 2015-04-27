class AnalysisSlocSet < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :sloc_set

  scope :for_repository, ->(repository_id) { joins(sloc_set: :repository).where(repositories: { id: repository_id }) }
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

  private

  def self.sanitize_sql_condition(file_name)
    sanitize_sql_for_conditions(["fyles.name like '%s%%'", sanitize_sql_like(file_name)])
  end

  def adjust_leading_slash(file_name)
    if sloc_set.code_set.repository.is_a? SvnSyncRepository
      file_name.gsub(/^[^\/]/, '/\0')
    else
      file_name.gsub(/^\//, '')
    end
  end
end
