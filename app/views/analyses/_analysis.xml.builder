language_percentages = Analysis::LanguagePercentages.new(analysis).collection

xml.analysis do
  tms = analysis.twelve_month_summary
  xml.id analysis.id
  xml.url project_analysis_url(analysis.project, analysis, format: :xml)
  xml.project_id analysis.project_id
  xml.updated_at(analysis.updated_on.iso8601) if analysis.updated_on
  xml.oldest_code_set_time(analysis.oldest_code_set_time.iso8601) if analysis.oldest_code_set_time
  xml.min_month(analysis.min_month.iso8601) if analysis.min_month
  xml.max_month(analysis.max_month.iso8601) if analysis.max_month
  xml.twelve_month_contributor_count analysis.headcount
  xml.total_contributor_count analysis.committers_all_time
  xml.twelve_month_commit_count tms.commits_count if tms
  xml.total_commit_count analysis.commit_count
  xml.total_code_lines analysis.code_total
  if analysis.factoids && analysis.factoids.any?
    xml.factoids do
      analysis.factoids.to_a.reject { |f| f.type.to_s =~ /FactoidDistribution|FactoidStaff/ }.each do |f|
        xml.factoid type: f.class do
          xml.text! f.to_s
        end
      end
    end
  end
  if language_percentages.any?
    xml.languages graph_url: "#{project_url(analysis.project)}/analyses/#{analysis.id}/languages.png" do
      language_percentages.each do |id, name, attr|
        percent = attr[:percent] > 0 ? attr[:percent].to_s : '<1'
        xml.language percentage: percent, color: attr[:color], id: id do
          xml.text! name
        end
      end
    end
  end
  if analysis.main_language_id
    xml.main_language_id analysis.main_language_id
    xml.main_language_name analysis.main_language.nice_name
  end
end
