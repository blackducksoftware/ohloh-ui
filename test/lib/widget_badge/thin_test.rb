require 'test_helper'
require 'test_helpers/image_helper'

# rubocop: disable Lint/UnneededSplatExpansion
describe 'WidgetBadge::Thin' do
  describe '#create' do
    # We were unable to compare the gifs. So we instead just check for successful method call.
    it 'must complete the operation without any exceptions' do
      strings = [
        { text: 'The Battle for W...', align: :center },
        { text: '124k Lines', align: :center },
        { text: '$1.2M Cost', align: :center },
        { text: '21 Developers', align: :center },
        { text: 'Metrics by Ohloh', align: :center }
      ]

      WidgetBadge::Thin.create(strings)
    end
  end

  describe '#add_text' do
    it 'must produce an image with given text' do
      text = '124k Lines'
      options = { y_offset: -1, blur: 70 }

      result_image = WidgetBadge::Thin.send :add_text, *[text, options]
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'thin', 'openhub_and_text.png')

      compare_images(result_image.path, expected_image_path, 0.1)
    end
  end

  describe '#new_text_image' do
    it 'must create a image with a given text' do
      options = { y_offset: -1, blur: 70, align: :center }

      result_image = WidgetBadge::Thin.send :new_text_image, *['Some Text', options]
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'thin', 'new_text_image.png')

      compare_images(result_image.path, expected_image_path, 0.13)
    end
  end
end
# rubocop: enable Lint/UnneededSplatExpansion
