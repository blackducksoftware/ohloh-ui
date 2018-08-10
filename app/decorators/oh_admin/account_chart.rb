class OhAdmin::AccountChart
  def initialize(period)
    @period = period
    process_account_data(period)
  end

  def render
    chart = ACCOUNTS_CHART_DEFAULTS
    chart['series'][0][:data] = @spam.values
    chart['series'][1][:data] = @regular.values
    chart['series'][2][:data] = @total_count
    chart['xAxis']['tickInterval'] = set_interval(@period)
    chart['xAxis']['categories'] = @x_axis
    chart.to_json
  end

  private

  def process_account_data(period)
    from = period.months.ago.to_date
    yesterday = Date.yesterday
    @spam = spam_accounts(from, yesterday)
    @regular = regular_accounts(from, yesterday)
    @total_count = []
    @x_axis = []
    fill_zero_gaps(from, yesterday)
    sort_by_date
  end

  def fill_zero_gaps(from, yesterday)
    total_count_till_from_date = total_accounts(from)
    (from..yesterday).each do |date|
      @spam[date] = 0 if @spam[date].nil?
      @regular[date] = 0 if @regular[date].nil?
      total_count_till_from_date += @regular[date]
      @total_count <<  total_count_till_from_date
      @x_axis << date.strftime('%a, %b %d')
    end
  end

  def sort_by_date
    @spam = Hash[@spam.sort_by { |a, _b| a }]
    @regular = Hash[@regular.sort_by { |a, _b| a }]
  end

  def spam_accounts(from, to)
    Account.group('date(created_at)').where(created_at: from..to, level: Account::Access::SPAM).count
  end

  def regular_accounts(from, to)
    Account.group('date(created_at)').where(created_at: from..to, level: Account::Access::DEFAULT).count
  end

  def total_accounts(date)
    Account.where('DATE(created_at) < ?', date).where(level: Account::Access::DEFAULT).count
  end

  def set_interval(period)
    case period
    when 12 then 10
    when 6  then 5
    when 3  then 3
    end
  end
end
