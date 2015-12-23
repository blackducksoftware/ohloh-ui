def random_repository_name
  chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['_', '-', '+', '/', '.']
  (0...16).map { chars[rand(chars.length)] }.join
end

FactoryGirl.define do
  factory :repository do
    url { Faker::Internet.url }
    module_name { random_repository_name }
    branch_name { random_repository_name }
    type 'GitRepository'
    after(:create) { |repository| create(:enlistment, repository: repository) }
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
