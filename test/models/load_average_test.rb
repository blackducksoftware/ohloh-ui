require 'test_helper'

class LoadAverageTest < ActiveSupport::TestCase
  describe 'too_high?' do
    let(:load_average) { LoadAverage.create!(current: 5, max: 15) }

    it 'wont be true when current is lesser than max' do
      load_average.wont_be :too_high?
    end

    it 'must be true when current is greater than max' do
      load_average.update!(current: 16)
      load_average.must_be :too_high?
    end
  end
end
