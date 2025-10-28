# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    association :worker
    status { Job::STATUS_SCHEDULED }
  end

  factory :fis_job, class: :FisJob do
    association :worker
    status { Job::STATUS_SCHEDULED }
    code_location_id { Faker::Number.number(digits: 4) }
  end

  factory :fetch_job, parent: :fis_job, class: :FetchJob do
    type { 'FetchJob' }
  end

  factory :sloc_job, parent: :fis_job, class: :SlocJob do
    type { 'SlocJob' }
  end

  factory :organization_analysis_job, parent: :job, class: :OrganizationAnalysisJob do
    type { 'OrganizationAnalysisJob' }
  end

  factory :account_analysis_job, parent: :job, class: :AccountAnalysisJob do
    type { 'AccountAnalysisJob' }
  end

  factory :failed_job, parent: :fis_job, class: :FetchJob do
    type { 'FetchJob' }
    status { Job::STATUS_FAILED }
  end

  factory :failed_tarball_job, parent: :fis_job, class: :TarballJob do
    type { 'TarballJob' }
    status { Job::STATUS_FAILED }
  end

  factory :failed_project_analysis_job, parent: :job, class: :ProjectAnalysisJob do
    type { 'ProjectAnalysisJob' }
    status { Job::STATUS_FAILED }
  end

  factory :project_analysis_job, parent: :job, class: :ProjectAnalysisJob do
    type { 'ProjectAnalysisJob' }
  end
end
