xml.enlistment do
  xml.id enlistment.id
  xml.project_id enlistment.project_id
  xml.repository_id enlistment.repository_id
  # TODO: repository
  # render partial: '/repositories/repository', locals: { repository: enlistment.repository, builder: xml }
end
