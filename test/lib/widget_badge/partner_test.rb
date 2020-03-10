# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/image_helper'

# rubocop: disable Lint/UnneededSplatExpansion
describe 'WidgetBadge::Partner' do
  describe '#create' do
    it 'must create the badge successfully' do
      strings = [
        { text: '', logo: 'opencollabnet.png', align: :center },
        { text: 'Subversion subve', align: :center },
        { text: '124k Lines', align: :center },
        { text: '$1.2M Cost', align: :center },
        { text: '21 Developers', align: :center }
      ]
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'partner', 'badge.gif')

      result_blob = WidgetBadge::Partner.create(strings)
      result_image = write_to_file(result_blob)

      compare_images(result_image.path, expected_image_path, 0.29)
    end
  end

  describe '#add_text' do
    it 'must produce an image with name when it is present' do
      text = '124k Lines'
      options = { opacity: 70 }

      result_image = WidgetBadge::Partner.send :add_text, *[text, options]
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'partner', 'add_text.png')

      compare_images(result_image.path, expected_image_path, 0.38)
    end

    it 'must produce an image without name when it is absent' do
      text = ''
      options = { opacity: 70 }

      result_image = WidgetBadge::Partner.send :add_text, *[text, options]
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'partner', 'text_without_name.png')

      compare_images(result_image.path, expected_image_path, 0.29)
    end
  end

  describe '#new_text_image' do
    it 'must succesfully create a image with a given text' do
      options = WidgetBadge::Partner::DEFAULT_FONT_OPTIONS

      result_image = WidgetBadge::Partner.send :new_text_image, *['Some Text', options]
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'partner', 'new_text_image.png')

      compare_images(result_image.path, expected_image_path, 0.1)
    end
  end
end
# rubocop: enable Lint/UnneededSplatExpansion
