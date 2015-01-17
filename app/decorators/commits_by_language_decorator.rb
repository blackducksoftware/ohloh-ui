require 'ostruct'

class CommitsByLanguageDecorator < Draper::Decorator
  decorates :account
  delegate_all

  def initialize(start_date = Time.now.utc - 7.years, end_date = Time.now.utc)
    @start_date = start_date.strftime("%Y-%m-01").to_date
    @end_date = end_date.strftime("%Y-%m-01").to_date
  end

  def language_experience
    current_month_start = Date.today.beginning_of_month
    start_date = first_commit_date if params[:scope] == 'full'
    if first_commit_date.nil? || first_commit_date > current_month_start.years_ago(7)
      start_date = current_month_start.years_ago(7)
    end

    end_date = current_month_start.prev_month
    no_of_months = ((end_date - start_date)/1.month.second).to_i
    dates = no_of_months.times.each_with_object([]) do |count, array|
      array << start_date.beginning_of_month + count.months
    end
    language_experience_between(dates).to_json
  end

  private

  def filtered_commits_by_language(dates)
    return [] if best_vita.nil? || best_vita.vita_fact.nil? || best_vita.vita_fact.commits_by_language.nil?
    range = (dates.first..dates.last)
    best_vita.vita_fact.commits_by_language.select do |elem|
      range === Date.parse(elem["month"])
    end
  end

  def commits_by_language(dates = [])
    return filtered_commits_by_language(dates) unless dates.empty?
    @commits_by_language ||= begin
      return [] if best_vita.nil?
      best_vita.vita_fact.commits_by_language
    end
  end

  def language_experience(dates)
    facts, result = commits_by_language(dates), {}
    language_group = facts.group_by {|fact| fact['l_id']}
    facts = facts.group_by { |fact| fact['month']}

    dates.each do |date|
      date_text = date.strftime('%Y-%m-01')
      language_group.each do |l_id, afs|
        item = afs.first
        result[l_id] ||= OpenStruct.new(
          language_id: l_id, name: item['l_name'], color_code: language_color(item['l_name']),
          nice_name: item['l_nice_name'], commits: [], category: item['l_category'] )
        fact_this_month = (facts[date_text] || []).find { |f| l_id == f['l_id'] } || {}
        result[l_id].commits << fact_this_month['commits'].to_i
      end
    end
    {object_array: result.values.sort_by {|a| -a.commits.sum }, date_array: dates}
  end
end
