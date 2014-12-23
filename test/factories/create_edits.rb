FactoryGirl.define do
  factory :create_edit do
    type 'CreateEdit'
    target_type 'Foo'
    target_id 1
    key 'foobar'
    value '123'
    account_id 1
    project_id 1
    organization_id nil
    ip '0.0.0.0'
    undone false
    undone_at nil
    undone_by nil
  end
end
