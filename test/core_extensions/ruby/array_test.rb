require 'test_helper'

class ArrayTest < ActiveSupport::TestCase
  describe 'exclude' do
    it 'should exclude the given value' do
      fake_array = Faker::Lorem.words(4)
      exclude_word = fake_array.sample

      output_array = fake_array.exclude(exclude_word)

      output_array.count.must_equal 3
      output_array.include?(exclude_word).must_equal false
    end

    it 'should exclude for multiple arguments' do
      fake_array = %w[voluptatem a sit commodi]
      exclude_word1, exclude_word2 = fake_array.sample(2)

      output_array = fake_array.exclude(exclude_word1, exclude_word2)

      output_array.count.must_equal 2
      output_array.include?(exclude_word1).must_equal false
      output_array.include?(exclude_word2).must_equal false
    end
  end
end
