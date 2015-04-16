class AnalysisSlocSet < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :sloc_set

  scope :for_repository, ->(repository_id) { joins(sloc_set: :repository).where(repositories: { id: repository_id }) }
  scope :for_analysis, ->(analysis_id) { where(analysis_id: analysis_id) }

  def ignore_tuples
    conditions = ignore_prefixes.collect do |prefix|
      sanitize_sql_for_conditions(['fyles.name like %s%%', sanitize_sql_like(prefix)])
    end.join(' OR ')
    conditions.concat(" and fyles.code_set_id = #{sloc_set.code_set_id}") if conditions.present?
  end

  def ignore_prefixes
    Ignore.parse(ignore).map { |prefix| adjust_leading_slash(prefix) }
  end

  private

  def adjust_leading_slash(file_name)
    is_directory = file_name.starts_with?('/')
    if sloc_set.code_set.repository.is_a? SvnSyncRepository
      is_directory ? file_name : file_name.prepend('/')
    else
      is_directory ? file_name.from(1) : file_name
    end
  end
end
