# frozen_string_literal: true

desc 'Updates the project stats in admin page'

task admin_project_stats: :environment do
  analyses_count = Project.joins(:best_analysis)
                          .where('analyses.updated_on >= ? and analyses.updated_on <= ?', 1.hour.ago, Time.current).size
  Rails.cache.write('Admin-project-analyses-count-cache', analyses_count)

  projects_count = Project.active.joins(:enlistments, :best_analysis)
                          .where('analyses.updated_on < ?', 2.weeks.ago.to_date).distinct.size
  Rails.cache.write('Admin-outdated-project-count-cache', projects_count)

  updated_project_count = Project.active.joins(:enlistments, :best_analysis)
                                 .where(analyses: { updated_on: 3.days.ago..Time.current }).distinct.size
  Rails.cache.write('Admin-updated-project-count-cache', updated_project_count)

  weeks_updated_project_count = Project.active.joins(:enlistments, :best_analysis)
                                       .where(analyses: { updated_on: 2.weeks.ago..3.days.ago }).distinct.size

  Rails.cache.write('Admin-weeks-updated-project-count-cache', weeks_updated_project_count)
  Rails.cache.write('Admin-active-project-count-cache') { Project.active_enlistments.distinct.size }
end
