# frozen_string_literal: true

xml = xml_instance
detailed_info ||= false

xml.org do
  xml.name organization.name
  xml.url organization_url organization, format: 'xml'
  xml.html_url organization_url organization
  xml.created_at organization.created_at.utc.xmlschema
  xml.updated_at organization.updated_at.utc.xmlschema
  xml.description organization.description
  xml.homepage_url organization.homepage_url
  xml.url_name organization.vanity_url
  xml.vanity_url organization.vanity_url
  xml.type organization.org_type_label

  if organization.logo_id
    xml.medium_logo_url organization.logo.attachment.url(:med)
    xml.small_logo_url organization.logo.attachment.url(:small)
  end

  if detailed_info
    render partial: '/organizations/show/pictogram', locals: { org: organization, xml_instance: xml, print_icon: true }
    render partial: "/organizations/show/#{@view}", locals: { org: organization, xml_instance: xml }
  else
    xml.projects_count organization.projects_count
    xml.affiliated_committers organization.affiliators_count
  end
end
