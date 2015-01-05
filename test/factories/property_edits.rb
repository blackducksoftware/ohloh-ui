FactoryGirl.define do
  factory :property_edit do
    type 'PropertyEdit'
    target_type 'Project'
    target_id 1
    key 'name'
    value 'Linux 2: Electric Boogaloo'
    account_id 1
    project_id 1
    organization_id nil
    ip '0.0.0.0'
    undone false
    undone_at nil
    undone_by nil
  end
end
