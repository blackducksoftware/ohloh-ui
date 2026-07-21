# frozen_string_literal: true

require 'test_helper'

class RatingsHelperTest < ActionView::TestCase
  include RatingsHelper

  describe 'rating_stars' do
    it 'returns span with given id' do
      result = rating_stars('test-id', 3)
      _(result).must_match(/<span id="test-id"/)
    end

    it 'includes schema markup with score' do
      result = rating_stars('test-id', 4)
      _(result).must_match(/itemprop="ratingValue"/)
      _(result).must_match(/4/)
    end

    it 'includes svg star rating' do
      result = rating_stars('test-id', 3)
      _(result).must_match(/<svg/)
    end
  end

  describe 'svg_star_rating' do
    it 'renders 5 star svgs' do
      result = send(:svg_star_rating, 3)
      _(result.scan('<svg').length).must_equal 5
    end

    it 'renders full stars for integer score' do
      result = send(:svg_star_rating, 5)
      _(result).must_match(/#ffb91a/)
      _(result).wont_match(/#d1d5db/)
    end

    it 'renders empty stars for zero score' do
      result = send(:svg_star_rating, 0)
      _(result).must_match(/#d1d5db/)
      _(result).wont_match(/#ffb91a/)
    end

    it 'renders half star for fractional score' do
      result = send(:svg_star_rating, 2.5)
      _(result).must_match(/linearGradient/)
    end

    it 'applies mini size 12px when mini: true' do
      result = send(:svg_star_rating, 3, mini: true)
      _(result).must_match(/12px/)
      _(result).wont_match(/14px/)
    end

    it 'applies normal size 14px when mini: false' do
      result = send(:svg_star_rating, 3, mini: false)
      _(result).must_match(/14px/)
    end
  end

  describe 'build_star_for_rating' do
    it 'builds full star when star <= score' do
      result = send(:build_star_for_rating, 3, 3, false)
      _(result).must_match(/#ffb91a/)
    end

    it 'builds half star when star - 0.5 <= score < star' do
      result = send(:build_star_for_rating, 3, 2.5, false)
      _(result).must_match(/linearGradient/)
    end

    it 'builds empty star when star > score + 0.5' do
      result = send(:build_star_for_rating, 5, 3, false)
      _(result).must_match(/#d1d5db/)
    end
  end

  describe 'build_star_svg' do
    it 'returns svg with given color' do
      result = send(:build_star_svg, '#ffb91a')
      _(result).must_match(/#ffb91a/)
      _(result).must_match(/<svg/)
    end

    it 'uses 14px size by default' do
      result = send(:build_star_svg, '#ffb91a')
      _(result).must_match(/14px/)
    end

    it 'uses 12px size when mini: true' do
      result = send(:build_star_svg, '#ffb91a', mini: true)
      _(result).must_match(/12px/)
    end
  end

  describe 'build_half_star_svg' do
    it 'returns svg with linearGradient' do
      result = send(:build_half_star_svg)
      _(result).must_match(/linearGradient/)
    end

    it 'uses 14px size by default' do
      result = send(:build_half_star_svg)
      _(result).must_match(/14px/)
    end

    it 'uses 12px size when mini: true' do
      result = send(:build_half_star_svg, mini: true)
      _(result).must_match(/12px/)
    end

    it 'includes both gradient stop colors' do
      result = send(:build_half_star_svg)
      _(result).must_match(/#ffb91a/)
      _(result).must_match(/#d1d5db/)
    end

    it 'generates unique gradient id per call' do
      result1 = send(:build_half_star_svg)
      result2 = send(:build_half_star_svg)
      id1 = result1.match(/id="(half-star-[^"]+)"/)[1]
      id2 = result2.match(/id="(half-star-[^"]+)"/)[1]
      _(id1).wont_equal id2
    end
  end

  describe 'rating_star_schema' do
    it 'includes aggregateRating schema markup' do
      result = send(:rating_star_schema, 4)
      _(result).must_match(/aggregateRating/)
      _(result).must_match(/AggregateRating/)
    end

    it 'includes ratingValue with score' do
      result = send(:rating_star_schema, 4)
      _(result).must_match(/ratingValue/)
      _(result).must_match(/4/)
    end
  end
end
