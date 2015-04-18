class Analysis::CommitVolumeChart
  DEFAULT_NAME_COUNT = 5
  INTERVALS = ['50 years', '12 months', '1 month']
  OTHER = 'Other'

  def initialize(analysis)
    @analysis = analysis
    @history = Analysis::CommitVolume.new(analysis)
  end

  def data
    COMMIT_VOLUME_CHART_DEFAULTS.merge(
      'series' => pivoted_series.map { |name, data| { 'name' => name, 'data' => data } },
      'xAxis' => { 'categories' => interval_labels },
      'warning' => warning_message(series[1])
    )
  end

  private

  def regroup(top_names, a)
    result = []
    other_count = 0

    a.each do |name, count|
      if top_names.include? name
        result << [name, count]
      else
        other_count += count
      end
    end

    result << [OTHER, other_count] if other_count > 0
    result
  end

  def interval_labels
    ['All Time', 'Past 12 Months', @analysis.max_month.strftime('%B %Y')]
  end

  def series
    @series ||= {}
    n = DEFAULT_NAME_COUNT
    @series[n] ||= begin
      queries = INTERVALS.map { |interval| commits_by_name(interval) }
      top_names = queries.map { |s| s[0..(n-1)].map(&:first) }.flatten.sort.uniq
      queries.map { |s| regroup(top_names, s) }
    end
  end

  def pivoted_series
    @pivoted_series ||= {}
    @pivoted_series[DEFAULT_NAME_COUNT] ||= begin
       all_names = []
       series.each do |s|
         s.each do |name, count|
           all_names << name unless all_names.include? name
         end
       end

       result = all_names.map { |name| [name, []] }

       series.each do |s|
         all_names.each_with_index do |name, i|
           n, count = s.find { |n, c| n == name }
           result[i][1] << count.to_i
         end
       end
       result
     end
  end

  def warning_message(s)
    half = s.map{ |name, count| count }.sum / 2
    s.each do |name, count|
      if count > half and name != OTHER
        return "#{name} generated more than 50% of all commits during the past 12 months."
      end
    end
    nil
  end
end
