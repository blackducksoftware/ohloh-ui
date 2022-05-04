# frozen_string_literal: true

class OhAdmin::AccountChart
  def initialize(period, filter)
    @period = period
    @filter = filter
    @from = period.months.ago.to_date
    @to = Date.yesterday
    account_data
  end

  def render
    chart = ACCOUNTS_CHART_DEFAULTS
    set_series_data(chart)
    chart['xAxis']['categories'] = @x_axis.uniq
    chart.to_json
  end

  private

  def set_series_data(chart)
    chart['series'][0][:data] = @spam.values
    chart['series'][1][:data] = @regular.values
    chart['series'][2][:data] = @total_count
  end

  def account_data
    @spam = spam_accounts
    @regular = regular_accounts
    monthly_data if @filter == 'monthly'
    @x_axis = []
    @total_count = []
    @filter == 'monthly' ? fill_zero_gaps_monthly : fill_zero_gaps
    sort_by_date
    @total_count = @regular.values if @filter == 'monthly'
  end

  def monthly_data
    @spam = @spam.inject({}) { |memo, (k, v)| memo.merge(k.strftime('%b %Y') => v) }
    @regular = @regular.inject({}) { |memo, (k, v)| memo.merge(k.strftime('%b %Y') => v) }
  end

  def fill_zero_gaps
    total_count_till_from_date = total_accounts(@from)
    (@from..@to).each do |date|
      @spam[date] = 0 if @spam[date].nil?
      @regular[date] = 0 if @regular[date].nil?
      total_count_till_from_date += @regular[date]
      @total_count <<  total_count_till_from_date if total_count_till_from_date
      @x_axis << date.strftime('%a, %b %d')
    end
  end

  def fill_zero_gaps_monthly
    (@from..@to).map { |date| date.strftime('%b %Y') }.uniq.each do |date|
      @spam[date] = 0 if @spam[date].nil?
      @regular[date] = 0 if @regular[date].nil?
      @x_axis << date
    end
  end

  def sort_by_date
    if @filter == 'monthly'
      @regular = @regular.sort_by { |month, _count| Date.strptime(month, '%b %Y') }.to_h
      @spam = @spam.sort_by { |month, _count| Date.strptime(month, '%b %Y') }.to_h
    else
      @spam = @spam.sort_by { |date, _count| date }.to_h
      @regular = @regular.sort_by { |date, _count| date }.to_h
    end
  end

  def spam_accounts
    if @filter == 'monthly'
      Account.group("DATE_TRUNC('month', created_at)").where(created_at: @from..@to, level: Account::Access::SPAM).count
    else
      Account.group('date(created_at)').where(created_at: @from..@to, level: Account::Access::SPAM).count
    end
  end

  def regular_accounts
    if @filter == 'monthly'
      Account.group("DATE_TRUNC('month', created_at)")
             .where(created_at: @from..@to, level: Account::Access::DEFAULT).count
    else
      Account.group('date(created_at)').where(created_at: @from..@to, level: Account::Access::DEFAULT).count
    end
  end

  def total_accounts(date)
    Account.where('DATE(created_at) < ?', date).where(level: Account::Access::DEFAULT).count
  end
end
