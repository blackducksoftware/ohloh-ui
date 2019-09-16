# frozen_string_literal: true

xml = xml_instance
affl_committers_stats = org.affiliated_committers_stats
out_committers_stats = org.outside_committers_stats

xml.infographic_details do
  xml.outside_committers out_committers_stats['out_committers'].to_i
  xml.outside_committers_commits out_committers_stats['out_commits'].to_i
  xml.projects_having_outside_commits out_committers_stats['out_projs'].to_i

  xml.portfolio_projects org.projects_count

  xml.affiliators org.affiliators_count
  xml.affiliators_committing_to_portfolio_projects affl_committers_stats['affl_committers'].to_i
  xml.affiliator_commits_to_portfolio_projects affl_committers_stats['affl_commits'].to_i
  xml.affiliators_commiting_projects affl_committers_stats['affl_projects'].to_i

  xml.outside_projects affl_committers_stats['affl_projects_out'].to_i
  xml.outside_projects_commits affl_committers_stats['affl_commits_out'].to_i
  xml.affiliators_committing_to_outside_projects affl_committers_stats['affl_committers_out'].to_i
end
