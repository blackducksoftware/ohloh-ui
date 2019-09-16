# frozen_string_literal: true

require 'test_helper'

class IconTest < ActiveSupport::TestCase
  describe 'image' do
    it 'should return logo when logo is present' do
      logo = create(:attachment)
      project = create(:project, logo_id: logo.id)

      image = '<img style="width:32px; height:32px; border:0 none;" '\
              "itemprop=\"image\" alt=\"#{project.name}\" src=\"#{project.logo.attachment.url(:small)}\" />"
      Icon.new(project).image.must_equal image
    end

    it 'should return image like text when logo is not present' do
      org = create(:organization)
      markup = '<p style="background-color:#EEE; color:#000; border:1px dashed #000;font-size:26px; '\
                'line-height:32px; width:32px; height:32px;text-align:center; '\
                "float:left; margin-bottom:0; margin-top:3px; margin-right:2px\">#{org.name[0].capitalize}</p>"
      Icon.new(org).image.must_equal markup
    end
  end
end
