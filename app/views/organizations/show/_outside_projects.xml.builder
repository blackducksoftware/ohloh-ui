xml = xml_instance

xml.outside_projects do
  @outside_projects.each do |pro|
    xml.project do
      xml.name pro.name
      xml.activity project_activity_text(pro, false)
      xml.claimed_by pro.organization ? pro.organization.name : ''
      xml.i_use_this pro.user_count
      xml.community_rating pro.rating_average.to_f.round(1).to_s
      xml.affiliates_contributing pro.contribs_count
      xml.commits_by_current_affiliates pro.commits
    end
  end
  xml.detailed_page_url "/orgs/#{@organization.vanity_url}/outside_projects"
end
