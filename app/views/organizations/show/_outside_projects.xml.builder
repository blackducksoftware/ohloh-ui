xml = xml_instance

xml.outside_projects do
  @projects.each do |pro|
    xml.project do
      xml.name pro.name
      xml.activity project_activity_text(pro, false)
      xml.claimed_by pro.claimed_by
      xml.i_use_this pro.user_count
      xml.community_rating "#{pro.rating_average.to_f.round(1)}"
      xml.affiliates_contributing pro.contribs_count
      xml.commits_by_current_affiliates pro.commits
    end
  end
  xml.detailed_page_url "/orgs/#{org.url_name}/outside_projects"
end
