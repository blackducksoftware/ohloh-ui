code_location = enlistment.code_location
xml.enlistment do
  xml.id enlistment.id
  xml.project_id enlistment.project_id
  xml.code_location do
    xml.id code_location.id
    xml.type code_location.scm_type
    xml.url code_location.url
    xml.module_name code_location.branch if code_location.branch.present?
    xml.username code_location.username
    xml.password code_location.password
    xml.logged_at code_location.best_code_set_id ? xml_date_to_time(code_location.best_code_set.logged_at) : nil
    xml.commits((code_location.best_code_set_id ? code_location.best_code_set.as_of : 0 ).to_i)
    xml.ohloh_job_status code_location.failed? ? 'failed' : 'success'
  end
end
