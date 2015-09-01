FactoryGirl.define do
  factory :job do
    slave Slave.where(hostname: Socket.gethostname).first_or_create!
    status Job::STATUS_SCHEDULED
  end

  factory :fetch_job, parent: :job, class: :FetchJob do
    type 'FetchJob'
  end

  factory :import_job, parent: :job, class: :ImportJob do
    type 'ImportJob'
  end

  factory :vita_job, parent: :job, class: :VitaJob do
    type 'VitaJob'
  end
end
