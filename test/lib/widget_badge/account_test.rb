# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/image_helper'

describe 'WidgetBadge::Account' do
  describe '#create' do
    it 'must create the badge successfully' do
      options = { kudo_rank: 1, name: 'sara', kudos: 2, commits: 39 }
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'account', 'badge.png')

      result_blob = WidgetBadge::Account.create(options)
      result_file = write_to_file(result_blob)

      compare_images(result_file.path, expected_image_path, 0.1)
    end

    it 'must handle spaces and utf-8 characters in account names' do
      options = { kudo_rank: 1, name: 'Stefan Küng', kudos: 2, commits: 39 }
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'account', 'fancy_name.png')

      result_blob = WidgetBadge::Account.create(options)
      result_file = write_to_file(result_blob)

      compare_images(result_file.path, expected_image_path, 0.7)
    end
  end

  describe '#add_text' do
    let(:base_image) { WidgetBadge::Account.send(:setup_blank) }

    it 'must produce an image without text when no name' do
      options = { kudo_rank: 1, kudos: 2, commits: 39 }

      result_image = WidgetBadge::Account.send :add_text, base_image, options
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'account', 'text_without_name.png')

      compare_images(result_image.path, expected_image_path, 0.8)
    end

    it 'must produce an image without commits and kudos when not present' do
      options = { kudo_rank: 1, name: 'sara' }

      result_image = WidgetBadge::Account.send :add_text, base_image, options
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge',
                                            'account', 'text_without_commits_and_kudos.png')

      compare_images(result_image.path, expected_image_path, 0.1)
    end
  end

  describe '#new_text_image' do
    it 'must succesfully create a image with a given text' do
      options = WidgetBadge::Account::DEFAULT_FONT_OPTIONS

      result_image = WidgetBadge::Account.send :new_text_image, 'Some Text', options
      expected_image_path = Rails.root.join('test', 'data', 'widget_badge', 'account', 'new_text_image.png')

      compare_images(result_image.path, expected_image_path, 0.1)
    end
  end
end
