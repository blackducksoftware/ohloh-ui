# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  WINDOW = { ten_minutes: 10.minutes, one_hour: 1.hour, two_hours: 2.hours, eight_hours: 8.hours,
             one_day: 1.day, two_days: 2.days, one_week: 1.week, one_month: 1.month,
             all: 20.years }.freeze

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
  Time.current.ago(WINDOW[window_param.to_sym]) || 1.hour.ago
end
