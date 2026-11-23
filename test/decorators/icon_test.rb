# frozen_string_literal: true

require 'test_helper'

class IconTest < ActiveSupport::TestCase
  describe 'image' do
    it 'should return logo when logo is present' do
      logo = create(:attachment)
      project = create(:project, logo_id: logo.id)

      icon = Icon.new(project)
      result = icon.image

      # Check that it's wrapped in a div with icon-container and has-logo classes
      _(result).must_match(/<div class="icon-container has-logo">/)
      # Check that it contains an img tag with correct attributes
      _(result).must_match(/itemprop="image"/)
      _(result).must_match(/alt="#{project.name}"/)
      _(result).must_match(/src="#{project.logo.attachment.url(:small)}"/)
      # Check that it contains a span with icon-letter class
      _(result).must_match(/<span class="icon-letter" style="display:none">/)
      _(result).must_match(/<\/span><\/div>/)
    end

    it 'should return image like text when logo is not present' do
      org = create(:organization)
      icon = Icon.new(org)
      result = icon.image

      # Check that it's wrapped in a div with icon-container class
      _(result).must_match(/<div class="icon-container">/)
      # Check that it contains a span with icon-letter class and the first letter of the name
      _(result).must_match(/<span class="icon-letter">#{org.name[0].upcase}<\/span>/)
      _(result).must_match(/<\/div>/)
    end
  end
end
