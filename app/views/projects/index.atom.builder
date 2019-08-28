# frozen_string_literal: true

xml.instruct!
xml.feed(xmlns: 'http://www.w3.org/2005/Atom') do
  xml.link(projects_url)
  xml.title('Open Hub Projects Feed')
  xml.id(projects_url)

  @projects.each do |project|
    xml.entry do
      xml.title(project.name)
      xml.link(href: project_url(project))
      xml.description(project.description)
      xml.pub_date(project.created_at.strftime('%Y-%m-%dT%H:%M:%S%Z'))
      xml.id(project_url(project))
    end
  end
end
