code_location = enlistment.code_location
repository = code_location.repository

xml.enlistment do
  xml.id enlistment.id
  xml.project_id enlistment.project_id
  xml.repository_id repository.id
  xml.repository do
    xml.id repository.id
    xml.type repository.class.to_s
    xml.url repository.url
    xml.module_name code_location.module_branch_name if code_location.module_branch_name.present?
    xml.username repository.username
    xml.password repository.password
    xml.logged_at code_location.best_code_set_id ? xml_date_to_time(code_location.best_code_set.logged_at) : nil
    xml.commits((code_location.best_code_set_id ? code_location.best_code_set.as_of : 0 ).to_i)
    xml.ohloh_job_status code_location.failed? ? 'failed' : 'success'
  end
end
