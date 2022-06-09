# frozen_string_literal: true

require 'csv'

desc 'Fetch status of project from csv file'

task project_status: :environment do
  col_data = []
  exception = ''
  CSV.foreach('vendor/top_250_components_high_activity_status_2021.csv') { |row| col_data << row[0] }
  col_data.shift
  file = "#{Rails.root}/vendor/project_data.csv"

  headers = %w[component_parent_name last_analysis_date exception status]

  CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
    col_data.each do |val|
      project = Project.find_by_name(val)
      analyzed_on = project.best_analysis&.updated_on if project
      if analyzed_on && analyzed_on < 2.months.ago
        project.enlistments.each do |en|
          exception = en.code_location.jobs.last&.exception if en.code_location.do_not_fetch == true
        end
      elsif analyzed_on && analyzed_on > 2.months.ago
        status = 'Active'
      end
      writer << [val, analyzed_on, exception, status]
    end
  end
end
