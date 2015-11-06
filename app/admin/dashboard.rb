ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        render :partial => 'overview', :locals => {:window => @window}

        render :partial => 'job_overview', :locals => {:window => @window}
      end
    end
  end # content
end

def window_param
  params['window'] || 'one_hour'
end

def human_window
  window_param.humanize.titleize
end

def get_window
  case window_param.to_sym 
  when :ten_minutes then 10.minutes.ago
  when :one_hour then 1.hour.ago
  when :two_hours then 2.hours.ago
  when :eight_hours then 8.hours.ago
  when :one_day then 1.day.ago
  when :two_days then 2.days.ago
  when :one_week then 1.week.ago
  when :one_month then 1.month.ago
  when :all then 20.years.ago #built in obsolesce.  heh.
  else 1.hour.ago # default
  end
end
