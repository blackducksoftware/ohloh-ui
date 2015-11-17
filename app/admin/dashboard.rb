ActiveAdmin.register_page 'Dashboard' do
  WINDOW = { ten_minutes: 10.minutes.ago, one_hour: 1.hour.ago, two_hours: 2.hours.ago, eight_hours: 8.hours.ago,
             one_day: 1.day.ago, two_days: 2.days.ago, one_week: 1.week.ago, one_month: 1.month.ago,
             all: 20.years.ago }

  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        render partial: 'overview', locals: { window: @window }

        render partial: 'job_overview', locals: { window: @window }
      end
    end
  end
end

def window_param
  params['window'] || 'one_hour'
end

def human_window
  window_param.humanize.titleize
end

def get_window
  WINDOW[window_param.to_sym] || 1.hour.ago
end
