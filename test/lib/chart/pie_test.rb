require 'test_helper'
require 'test_helpers/image_helper'

describe 'Chart::Pie' do
  let(:data) do
    [{ url_name: 'xml', percent: 30, color: '555555' }, { url_name: 'sql', percent: 23, color: '493625' },
     { url_name: 'html', percent: 20, color: '47A400' }, { url_name: 'xml', percent: 27, color: '555555' }]
  end

  describe '#render' do
    it 'should render chart' do
      expected_image_path = Rails.root.join('test/data/chart/pie.png')
      result_file = Chart::Pie.new(data, nil, nil).render

      compare_images(result_file.path, expected_image_path, 0.1)
    end
  end
end
