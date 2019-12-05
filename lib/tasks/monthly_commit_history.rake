# frozen_string_literal: true

# FDW: joins FDW tables(commits, code_sets, sloc_sets, analysis_sloc_sets) for given analysis_id. #API

namespace :fisa do
  desc 'Populate monthly commit histories'
  task populate_monthly_commit_history: :environment do
    count = 0
    total_count = Project.where.not(best_analysis_id: nil).count

    Project.where.not(best_analysis_id: nil).select(:id, :best_analysis_id)
           .find_in_batches(batch_size: 100) do |projects|
      best_analysis_ids = projects.map(&:best_analysis_id)
      count += best_analysis_ids.count
      puts "Processing #{count} of #{total_count}"
      query = <<-INLINE_SQL
        insert into monthly_commit_histories(analysis_id, json)
          select analysis_id, json_object_agg(to_char(this_month, 'yyyy-MM-dd'), count)
          from (
            select analysis_sloc_sets.analysis_id, date_trunc('month', commits.time) this_month, count(*)
            from analysis_sloc_sets
            INNER JOIN sloc_sets ON sloc_sets.id = analysis_sloc_sets.sloc_set_id
            INNER JOIN code_sets ON code_sets.id = sloc_sets.code_set_id
            INNER JOIN commits ON commits.code_set_id = code_sets.id
            where analysis_sloc_sets.analysis_id in ('#{best_analysis_ids.join("', '")}')
            group by analysis_sloc_sets.analysis_id, this_month
          )T group by analysis_id;
      INLINE_SQL
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
