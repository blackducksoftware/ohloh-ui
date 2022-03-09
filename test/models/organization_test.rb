# frozen_string_literal: true

require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  let(:org) { create(:organization) }

  it 'unclaims projects when destroyed and reclaims them when undestroyed' do
    proj1 = create(:project)
    proj2 = create(:project)
    proj1.update(organization_id: org.id)
    proj2.update(organization_id: org.id)
    pe1 = PropertyEdit.where(target: proj1, key: 'organization_id', value: org.id.to_s).first
    pe2 = PropertyEdit.where(target: proj2, key: 'organization_id', value: org.id.to_s).first
    _(pe1.undone).must_equal false
    _(pe2.undone).must_equal false
    org.destroy
    _(pe1.reload.undone).must_equal true
    _(pe2.reload.undone).must_equal true
    _(proj1.reload.organization_id).must_be_nil
    _(proj2.reload.organization_id).must_be_nil
    CreateEdit.where(target: org).first.redo!(create(:admin))
    _(pe1.reload.undone).must_equal false
    _(pe2.reload.undone).must_equal false
    _(proj1.reload.organization_id).must_equal org.id
    _(proj2.reload.organization_id).must_equal org.id
  end

  describe 'managed_by' do
    it 'should return all orgs managed by an account' do
      account = create(:account)
      create(:manage, account: account, target: org)
      _(Organization.managed_by(account)).must_equal [org]
    end
  end

  describe 'CreateEdit' do
    it 'should not allow to undo a creat CreateEdit' do
      _(org.allow_undo?(nil)).must_equal false
    end
  end

  describe 'from_param' do
    it 'should match organization vanity_url' do
      organization = create(:organization)
      _(Organization.from_param(organization.vanity_url).first.id).must_equal organization.id
    end

    it 'should match organization id as string' do
      organization = create(:organization)
      _(Organization.from_param(organization.id.to_s).first.id).must_equal organization.id
    end

    it 'should match organization id as integer' do
      organization = create(:organization)
      _(Organization.from_param(organization.id).first.id).must_equal organization.id
    end

    it 'should not match deleted organizations' do
      organization = create(:organization)
      _(Organization.from_param(organization.to_param).count).must_equal 1
      organization.destroy
      _(Organization.from_param(organization.to_param).count).must_equal 0
    end
  end

  describe 'sort_by_newest' do
    it 'org' do
      org1 = create(:organization, name: 'test1')
      org2 = create(:organization, name: 'test2')

      _(Organization.sort_by_newest).must_equal [org2, org1]
    end
  end

  describe 'sort_by_recent' do
    it 'org' do
      org1 = create(:organization, name: 'test1', updated_at: Time.current + 5.days)
      org2 = create(:organization, name: 'test2')

      _(Organization.sort_by_recent).must_equal [org1, org2]
    end
  end

  describe 'sort_by_name' do
    it 'org' do
      org1 = create(:organization, name: 'test1')
      org2 = create(:organization, name: 'test2')

      _(Organization.sort_by_name).must_equal [org1, org2]
    end
  end

  describe 'sort_by_projects' do
    it 'org' do
      org1 = create(:organization, name: 'test1', projects_count: 5)
      org2 = create(:organization, name: 'test2', projects_count: 10)

      _(Organization.sort_by_projects).must_equal [org2, org1]
    end
  end

  describe 'search_and_sort' do
    it 'should return sorted search results' do
      org1 = create(:organization, name: 'test na1', projects_count: 5)
      org2 = create(:organization, name: 'test na2', projects_count: 10)
      org3 = create(:organization, name: 'test na3', projects_count: 9)

      _(Organization.search_and_sort('test', 'projects', nil)).must_equal [org2, org3, org1]
    end
  end

  describe 'affiliators_count' do
    it 'must return non zero count' do
      account = create(:account, organization_id: org.id)
      create_position(account: account)
      _(org.affiliators_count).must_equal 1
    end

    it 'must return zero if no positions found' do
      create(:account, organization_id: org.id)
      _(org.affiliators_count).must_equal 0
    end
  end

  describe 'jobs' do
    it 'ensure_job should not schedule organization job if there is a job already scheduled' do
      Job.delete_all
      assert_equal 0, OrganizationJob.count
      OrganizationJob.create(organization: org, wait_until: Time.current.utc + 6.hours)
      org.ensure_job
      assert_equal 1, OrganizationJob.count
    end

    it 'should create a job if job not exist?' do
      assert_difference 'OrganizationJob.count', 1 do
        org.ensure_job
      end
    end

    it 'schedule_analysis should schedule organization job successfully' do
      Job.delete_all
      assert_equal 0, OrganizationJob.count
      org.schedule_analysis
      assert_equal 1, OrganizationJob.count
    end

    it 'schedule_analysis should not schedule organization job if there is a job already scheduled' do
      Job.delete_all
      OrganizationJob.create(organization: org, wait_until: Time.current.utc + 6.hours)
      org.schedule_analysis
      assert_equal 1, OrganizationJob.count
    end

    it 'changing org_type should schedule an organization job' do
      Job.delete_all
      org.update_attribute(:org_type, 3)
      assert_equal 1, OrganizationJob.count
    end

    it 'changing other org attrs like name, description should not schedule an organization job' do
      Job.delete_all
      org_hash = { name: 'New name', vanity_url: 'url name', description: 'Desc1', homepage_url: '/org/new' }
      org_hash.each do |att, val|
        org.update_attribute(att, val)
        assert_equal 0, OrganizationJob.count
      end
    end

    it 'change in org deleted status should schedule an org job' do
      Job.delete_all
      org.update_attribute(:deleted, true)
      assert_equal 1, OrganizationJob.count
    end
  end

  describe 'validations' do
    describe 'vanity_url' do
      it 'must allow valid characters' do
        valid_vanity_urls = %w[org-name org_name orgé org_]
        valid_vanity_urls.each do |name|
          organization = build(:organization, vanity_url: name)
          _(organization).wont_be :valid?
        end
      end

      it 'wont allow invalid characters' do
        invalid_vanity_urls = %w[org.name .org -org _org]

        invalid_vanity_urls.each do |name|
          organization = build(:organization, vanity_url: name)
          _(organization).wont_be :valid?
        end
      end
    end
  end

  it 'must flag organization project for sync with KB' do
    project = create(:project, organization: org)

    org.update_attributes(name: Faker::Lorem.word + rand(999).to_s)
    _(KnowledgeBaseStatus.find_by(project_id: project.id).in_sync).must_equal false
  end
end
