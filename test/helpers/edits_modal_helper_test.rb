# frozen_string_literal: true

require 'test_helper'

describe EditsModalHelper do
  include FactoryBot::Syntax::Methods
  include ActionView::Helpers::UrlHelper
  include EditsHelper
  include ApplicationHelper
  # Add Rails routing helpers
  include Rails.application.routes.url_helpers

  describe '#edit_show_value' do
    # Set up routing context before each test

    before do
      @routes = Rails.application.routes
      default_url_options[:host] = 'test.host'

      # Set up a mock controller context for link_to to work
      @controller = OpenStruct.new(
        request: OpenStruct.new(
          protocol: 'http://',
          host: 'test.host'
        )
      )

      # Make controller method available
      define_singleton_method(:controller) { @controller }
    end
    it 'should return value for edit' do
      edit = create(:property_edit)
      _(edit_show_value(edit)).must_equal edit.value
    end

    it 'should retuen link for create edit' do
      edit = create(:create_edit)
      _(edit_show_value(edit)).must_equal link_to edit.target.to_param, edit.target
    end

    it 'should return vlaue for alias name' do
      Alias.any_instance.stubs(:schedule_project_analysis)
      alias_obj = create(:alias)
      edit = create(:property_edit, target: alias_obj, value: alias_obj.preferred_name_id)
      _(edit_show_value(edit)).must_equal alias_obj.preferred_name.name
    end

    it 'should return value for permission' do
      permission = create(:permission)
      _(edit_show_value(permission.edits.first)).must_equal I18n.t('edits.everyone')
    end

    it 'should return value for enlistment' do
      ApiAccess.stubs(:available?).returns(true)
      WebMocker.get_code_location
      enlistment = create_enlistment_with_code_location
      _(enlistment.edits.first.target.code_location.nice_url).must_equal enlistment.code_location.nice_url
    end

    it 'should return value for project license' do
      project_license = create(:project_license)
      _(edit_show_value(project_license.edits.first)).must_equal link_to project_license.license.to_param.to_s,
                                                                         "/licenses/#{project_license.license.to_param}"
    end

    it 'should return value for rss_sunscription' do
      rss_subscription = create(:rss_subscription)
      url = rss_subscription.rss_feed.url
      _(edit_show_value(rss_subscription.edits.first)).must_equal link_to url, url
    end

    it 'should return value for link' do
      link = create(:link)
      _(edit_show_value(link.edits.first)).must_equal link_to link.url, link.url
      _(edit_show_value(link.edits.last)).must_equal Link.find_category_by_id(link.link_category_id)
    end

    it 'should return value for logo' do
      logo = create(:logo)
      edit = create(:create_edit, key: 'logo_id', value: logo.id)
      url = logo.attachment.url(:med)
      _(edit_show_value(edit)).must_equal link_to url, url
    end

    it 'should return value for organization' do
      organization = create(:organization)
      org_type_edit = organization.edits.where(key: 'org_type').first
      _(edit_show_value(org_type_edit)).must_equal organization.org_type_label
    end
  end
end
