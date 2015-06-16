repository = enlistment.repository

xml.enlistment do
  xml.id enlistment.id
  xml.project_id enlistment.project_id
  xml.repository_id enlistment.repository_id
  xml.repository do
    xml.id repository.id
    xml.type repository.class.to_s
    xml.url repository.url
    xml.module_name repository.module_name if repository.module_name && !repository.module_name.blank?
    xml.username repository.username
    xml.password repository.password
    xml.logged_at repository.best_code_set_id ? xml_date_to_time(repository.best_code_set.logged_at) : nil
    xml.commits((repository.best_code_set_id ? repository.best_code_set.as_of : 0 ).to_i)
    xml.ohloh_job_status repository.failed? ? 'failed' : 'success'
  end
end
