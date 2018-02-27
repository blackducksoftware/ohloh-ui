require 'test_helper'

describe EditsModalHelper do
  include EditsHelper
  include ApplicationHelper

  describe '#edit_show_value' do
    it 'should return value for edit' do
      edit = create(:property_edit)
      edit_show_value(edit).must_equal edit.value
    end

    it 'should retuen link for create edit' do
      edit = create(:create_edit)
      edit_show_value(edit).must_equal link_to edit.target.to_param, edit.target
    end

    it 'should return vlaue for alias name' do
      Alias.any_instance.stubs(:schedule_project_analysis)
      alias_obj = create(:alias)
      edit = create(:property_edit, target: alias_obj, value: alias_obj.preferred_name_id)
      edit_show_value(edit).must_equal alias_obj.preferred_name.name
    end

    it 'should return value for permission' do
      permission = create(:permission)
      edit_show_value(permission.edits.first).must_equal I18n.t('edits.everyone')
    end

    it 'should return value for enlistment' do
      WebMocker.get_code_location
      enlistment = create_enlistment_with_code_location
      enlistment.edits.first.target.code_location.nice_url.must_equal enlistment.code_location.nice_url
    end

    it 'should return value for project license' do
      project_license = create(:project_license)
      edit_show_value(project_license.edits.first)
        .must_equal link_to project_license.license.to_param, project_license.license
    end

    it 'should return value for rss_sunscription' do
      rss_subscription = create(:rss_subscription)
      url = rss_subscription.rss_feed.url
      edit_show_value(rss_subscription.edits.first).must_equal link_to url, url
    end

    it 'should return value for link' do
      link = create(:link)
      edit_show_value(link.edits.first).must_equal link_to link.url, link.url
      edit_show_value(link.edits.last).must_equal Link.find_category_by_id(link.link_category_id)
    end

    it 'should return value for logo' do
      logo = create(:logo)
      edit = create(:create_edit, key: 'logo_id', value: logo.id)
      url = logo.attachment.url(:med)
      edit_show_value(edit).must_equal link_to url, url
    end

    it 'should return value for organization' do
      organization = create(:organization)
      org_type_edit = organization.edits.where(key: 'org_type').first
      edit_show_value(org_type_edit).must_equal organization.org_type_label
    end
  end
end
