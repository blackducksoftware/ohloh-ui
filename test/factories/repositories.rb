FactoryBot.define do
  factory :repository do
    url { Faker::Internet.url }
    type 'GitRepository'
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

  #  trait :branch do
  #    branch_name 'master'
  #    module_name nil
  #  end
  #
  #  trait :module do
  #    branch_name nil
  #    module_name 'trunk/'
  #  end
  #
  #  trait :no_branch_module do
  #    branch_name nil
  #    module_name nil
  #  end
end
