require 'test_helper'

describe Edits::DetailHelper do
  include EditsHelper
  delegate :request, to: :controller

  before do
    @project = create(:project)
    @organization = create(:project).organization
    @license = create(:project_license, project: @project).license
    @account = @project.editor_account
    @permission = create(:permission, target: @project, remainder: false)
    @alias = create(:alias, project: @project)
    @link = create(:link, project: @project)
    @enlistment = create(:enlistment, project: @project)
    @rss_subscription = create(:rss_subscription, project: @project)
  end

  describe 'edit_target_type' do
    describe '#Project Edit' do
      before do
        @parent = @project
      end

      it 'should display target type as project name' do
        edit = @project.edits.order(id: :asc).first
        edit_target_type(edit).must_equal "Project '#{@project.name}'"
      end
    end

    describe '#Organization Edit' do
      before do
        @parent = @organization
      end

      it 'should display target type as project name' do
        edit = @organization.edits.order(id: :asc).first
        edit_target_type(edit).must_equal "Organization '#{@organization.name}'"
      end
    end

    describe '#License Edit' do
      before do
        @parent = @license
      end

      it 'should display target type as project name' do
        edit = @license.edits.order(id: :asc).first
        edit_target_type(edit).must_equal "License '#{@license.name}'"
      end
    end

    describe '#Account Edit' do
      it 'should display target type as project name if target is Project' do
        edit = @project.edits.order(id: :asc).first
        edit_target_type(edit).must_equal "Project [<a href=\"#{project_url(@project)}\" "\
                                          "target=\"_blank\">#{@project.name}</a>]"
      end

      it 'should display target type as project name if target is Permission' do
        edit = @permission.edits.order(updated_at: :desc).first
        edit_target_type(edit).must_equal "Project [<a href=\"#{project_url(@project)}\" "\
                                          "target=\"_blank\">#{@project.name}</a>]"
      end

      it 'should display target type as project name if target is Alias' do
        edit = @alias.edits.first
        edit_target_type(edit).must_equal "Project [<a href=\"#{project_url(@project)}\" "\
                                          "target=\"_blank\">#{@project.name}</a>]"
      end
    end
  end

  describe 'edit_key' do
    describe '#Project Edit' do
      it "should return 'Organization' if key is organization_id" do
        @project.update(organization: create(:organization))
        edit = @project.edits.order(updated_at: :desc).first
        edit_key(edit).must_equal 'Organization'
      end

      it "should return 'Project' if key is empty" do
        edit = @project.edits.order(updated_at: :asc).first
        edit_key(edit).must_equal 'Project'
      end

      it "return 'Enlistment - Ignore' when change ignore files" do
        @enlistment.update(ignore: 'Disallow: lib/')
        edit = @enlistment.edits.order(updated_at: :desc).first
        edit_key(edit).must_equal 'Enlistment - Ignore'
      end
    end
  end

  describe 'edit_values' do
    describe '#Project Edit' do
      before do
        @parent = @project
      end

      it 'should return values of Project property' do
        edit = @project.edits.order(id: :asc).first
        edit_values(edit).must_equal new: { text: @project.name, href: project_url(@project) }
      end

      it 'should return values of description property' do
        @project.update(description: 'This is a project X')
        edit = @project.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: @project.description, old: nil
        Project.stubs(:aae_merge_within).returns(0.seconds)
        @project.update(description: 'This is a project Y')
        edit = @project.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: @project.description, old: 'This is a project X'
      end

      it 'should return values of Alias property' do
        edit = @alias.edits.first
        edit_values(edit).must_equal new: @alias.commit_name.name
        @alias.update(preferred_name_id: create(:name).id)
        edit = @alias.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal old: @alias.commit_name.name, new: @alias.preferred_name.name
      end

      it 'should return values of Permission property' do
        edit = @permission.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: t('edits.everyone')
        @permission.update(remainder: true)
        edit = @permission.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: t('edits.managers_only')
        Permission.stubs(:aae_merge_within).returns(0.seconds)
        @permission.update(remainder: false)
        edit = @permission.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: t('edits.everyone'), old: t('edits.managers_only')
      end

      it 'should return values of Link property' do
        edit = @link.edits.order(updated_at: :asc).first
        edit_values(edit).must_equal new: @link.url
        @link.update(title: 'Blackduck open hub demo')
        edit = @link.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: @link.title, old: nil
        @link.update(link_category_id: 9)
        edit = @link.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Homepage'
        Link.stubs(:aae_merge_within).returns(0.seconds)
        @link.update(link_category_id: 7)
        edit = @link.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Community', old: 'Homepage'
        @link.update(title: 'Blackduck open hub community')
        edit = @link.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Blackduck open hub community', old: 'Blackduck open hub demo'
      end

      it 'should return values of Enlistment property' do
        edit = @enlistment.edits.order(updated_at: :asc).first
        edit_values(edit).must_equal new: @enlistment.repository.url
        @enlistment.update(ignore: 'Disallow: lib/')
        edit = @enlistment.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: @enlistment.ignore, old: nil
        Enlistment.stubs(:aae_merge_within).returns(0.seconds)
        @enlistment.update(ignore: 'Disallow: lib/ Disallow tmp/')
        edit = @enlistment.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Disallow: lib/ Disallow tmp/', old: 'Disallow: lib/'
      end

      it 'should return values of Project License property' do
        proj_license = @project.project_licenses.first
        license = proj_license.license
        edit = proj_license.edits.order(updated_at: :asc).first
        edit_values(edit).must_equal new: { text: license.name,
                                            href: license_url(license) }
      end

      it 'should return values of RSS Subscription property' do
        edit = @rss_subscription.edits.order(updated_at: :asc).first
        edit_values(edit).must_equal new: { href: @rss_subscription.rss_feed.url }
      end

      it 'should return organization_url' do
        @project.update(organization: create(:organization, name: 'Blackduck'))
        pre_org = @project.organization
        controller.params = { project_id: @project.id }
        edit = @project.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: { text: 'Blackduck',
                                            href: organization_url(@project.organization) },
                                     old: nil
        Project.stubs(:aae_merge_within).returns(0.seconds)
        @project.update(organization: create(:organization, name: 'Black Duck'))
        edit = @project.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: { text: 'Black Duck',
                                            href: organization_url(@project.organization) },
                                     old: { text: 'Blackduck',
                                            href: organization_url(pre_org) }
      end
    end

    describe '#Organization Edit' do
      before do
        @parent = @organization
        controller.params = { organization_id: @organization.id }
      end

      it 'should return values of Organization property' do
        edit = @organization.edits.order(id: :asc).first
        edit_values(edit).must_equal new: { text: @organization.name,
                                            href: organization_url(@organization) }
        @organization.update(name: 'Blackduck')
        Organization.stubs(:aae_merge_within).returns(0.seconds)
        @organization.update(name: 'Black Duck')
        edit = @organization.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Black Duck', old: 'Blackduck'
      end

      it 'shoould return value of organization type' do
        @organization.update(org_type: 2)
        edit = @organization.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Education', old: nil
        Organization.stubs(:aae_merge_within).returns(0.seconds)
        @organization.update(org_type: 4)
        edit = @organization.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: 'Non-Profit', old: 'Education'
      end

      it 'should return logo url' do
        logo = create(:logo)
        controller.params = { organization_id: @organization.id }
        edit = PropertyEdit.new(target_type: @organization.class.name, target_id: @organization.id,
                                key: 'logo_id', value: logo.id)
        edit_values(edit).must_equal new: { img_src: logo.attachment.url(:med) }
      end

      it 'should return project url' do
        @project.update(organization: create(:organization))
        controller.params = { organization_id: @project.organization.id }
        edit = @project.edits.order(updated_at: :desc).first
        edit_values(edit).must_equal new: { text: @project.name,
                                            href: project_url(@project) }
      end
    end

    describe '#License Edit' do
      before do
        @parent = @license
      end

      it 'should return values of License property' do
        edit = @license.edits.order(id: :asc).first
        edit_values(edit).must_equal new: { text: @license.name,
                                            href: license_url(@license) }
      end
    end

    describe '#Account Edit' do
      it 'should return values of Project property' do
        edit = @project.edits.order(id: :asc).first
        edit_values(edit).must_equal new: { text: @project.name,
                                            href: project_url(@project) }
      end
    end

    it 'should return target_id edis is CreateEdit and not meets any condition' do
      account = create(:account, name: 'Fake edit history')
      edit = CreateEdit.new(target_type: account.class.name, target_id: account.id)
      edit_values(edit).must_equal new: account.id
    end
  end

  describe 'edit_format_value' do
    it 'should return formatted value' do
      link = %(<a href="http://host/p/sample" target="_new">http://host/p/sample</a>)
      edit_format_value('http://host/p/sample').must_equal link
      edit_format_value('Homepage').must_equal 'Homepage'
      value = { text: 'Sample', href: 'http://host/p/sample' }
      link = %(<a href="http://host/p/sample" target="_new">Sample</a>)
      edit_format_value(value).must_equal link
      value = { img_src: 'http://host/icons/12.png' }
      edit_format_value(value).must_equal %(<img src="http://host/icons/12.png"></img>)
    end
  end

  describe 'edit_show_path' do
    it 'should return edit show page relative url' do
      edit = @project.edits.first
      controller.params = { project_id: @project.id }
      edit_show_path(edit).must_equal "/p/#{@project.id}/edits/#{edit.id}"
      edit = @organization.edits.first
      controller.params = { organization_id: @organization.id }
      edit_show_path(edit).must_equal "/orgs/#{@organization.id}/edits/#{edit.id}"
      edit = @license.edits.first
      controller.params = { license_id: @license.id }
      edit_show_path(edit).must_equal "/licenses/#{@license.id}/edits/#{edit.id}"
      edit = @project.edits.first
      controller.params = { account_id: @account.id }
      edit_show_path(edit).must_equal "/accounts/#{@account.id}/edits/#{edit.id}"
    end
  end

  describe 'edit_generate_link' do
    it 'should return project url' do
      edit_generate_link(@project).must_equal "<a href=\"#{project_url(@project)}\" "\
                                              "target=\"_blank\">#{@project.name}</a>"
    end

    it 'should return organization url' do
      edit_generate_link(@organization).must_equal "<a href=\"#{organization_url(@organization)}\" "\
                                                    "target=\"_blank\">#{@organization.name}</a>"
    end

    it 'should return license url' do
      edit_generate_link(@license).must_equal "<a href=\"#{license_url(@license)}\" "\
                                              "target=\"_blank\">#{@license.name}</a>"
    end
  end
end
