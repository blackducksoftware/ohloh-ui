FactoryGirl.define do
  factory :repository do
    url { Faker::Internet.url }
    type 'GitRepository'

    after(:create) do |repository|
      create(:enlistment, repository: repository)
      repository.update! prime_code_location_attributes: { branch_name: :default } unless repository.prime_code_location
    end

    bypass_url_validation true
  end

  factory :bzr_repository, parent: :repository, class: 'BzrRepository' do
    type 'BzrRepository'
  end

  factory :cvs_repository, parent: :repository, class: 'CvsRepository' do
    type 'CvsRepository'
    url { ":pserver:anonymous:@cvs.sourceforge.net:/#{Faker::Lorem.word}/#{Faker::Lorem.word}" }
  end

  factory :git_repository, parent: :repository, class: 'GitRepository' do
    type 'GitRepository'
  end

  factory :hg_repository, parent: :repository, class: 'HgRepository' do
    type 'HgRepository'
  end

  factory :svn_repository, parent: :repository, class: 'SvnRepository' do
    type 'SvnRepository'
  end

  factory :svn_sync_repository, parent: :repository, class: 'SvnSyncRepository' do
    type 'SvnSyncRepository'
  end
end
