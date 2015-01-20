require 'ostruct'

class CommitsByLanguage < Draper::Decorator
  decorates :account
  delegate_all

  def initialize(*args)
    super
    start_date
    @end_date = Date.today.beginning_of_month.prev_month
  end

  def language_experience
    object_array = in_date_range.map { |_, entries| language(entries) }
    object_array.sort_by! { |a| -a.commits.sum }
    { object_array: object_array, date_array: dates }
  end

  def to_json
    language_experience.to_json
  end

  private

  def start_date
    seven_years_ago = Date.today.beginning_of_month.years_ago(7)
    @start_date = first_commit_date if @context[:scope] == 'full'
    @start_date = seven_years_ago if @start_date.nil? || @start_date > seven_years_ago
  end

  def in_date_range
    @in_date_range ||= best_vita.try(:vita_fact).try(:commits_by_language).to_a.select do |elem|
      (@start_date..@end_date).member? Date.parse(elem['month'])
    end
    @in_date_range.group_by { |fact| fact['l_id'] }
  end

  def dates
    @date_range ||= h.months_in_range(@start_date, @end_date)
  end

  def language(entries)
    language_entry = entries.first
    OpenStruct.new(language_id: language_entry['l_id'],
                   name: language_entry['l_name'],
                   color_code: h.language_color(language_entry['l_name']),
                   nice_name: language_entry['l_nice_name'],
                   commits: commits_by_months(entries),
                   category: language_entry['l_category'])
  end

  def commits_by_months(entries)
    commits_hash = entries.each_with_object({}) do |f, hsh|
      hsh[f['month']] = f['commits'].to_i
    end
    commits_hash.reverse_merge!(months_without_commits)
    commits_hash.sort_by { |k| k }.map(&:last)
  end

  def months_without_commits
    dates.each_with_object({}) do |date, hsh|
      hsh[date.strftime('%Y-%m-01')] = 0
    end
  end
end
