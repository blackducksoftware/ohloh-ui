# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/image_helper'

describe 'Chart::Pie' do
  let(:data) do
    [{ vanity_url: 'xml', percent: 30, color: '555555' }, { vanity_url: 'sql', percent: 23, color: '493625' },
     { vanity_url: 'html', percent: 20, color: '47A400' }, { vanity_url: 'xml', percent: 27, color: '555555' }]
  end

  describe '#render' do
    it 'should render chart' do
      expected_image_path = Rails.root.join('test', 'data', 'chart', 'pie.png')
      result_file = Chart::Pie.new(data, nil, nil).render

      compare_images(result_file.path, expected_image_path, 0.1)
    end
  end
end
