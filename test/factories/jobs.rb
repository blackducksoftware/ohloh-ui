FactoryBot.define do
  factory :job do
    association :slave
    status Job::STATUS_SCHEDULED
    code_location_id { Faker::Number.number(4) }
  end

  factory :fetch_job, parent: :job, class: :FetchJob do
    type 'FetchJob'
  end

  factory :sloc_job, parent: :job, class: :SlocJob do
    type 'SlocJob'
  end

  factory :complete_job, parent: :job, class: :CompleteJob do
    type 'CompleteJob'
  end

  factory :organization_job, parent: :job, class: :OrganizationJob do
    type 'OrganizationJob'
  end

  factory :vita_job, parent: :job, class: :VitaJob do
    type 'VitaJob'
  end

  factory :failed_job, parent: :job do
    type 'CompleteJob'
    status Job::STATUS_FAILED
  end

  factory :failed_tarball_job, parent: :job do
    type 'TarballJob'
    status Job::STATUS_FAILED
  end
end
