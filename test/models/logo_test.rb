# frozen_string_literal: true

require_relative '../test_helper'

class LogoTest < ActiveSupport::TestCase
  it 'class_exists' do
    _(Logo).must_be :present?
    _(Logo.new).must_be :present?
  end

  it 'invalid_file_type' do
    logo = Logo.create(attachment_file_name: 'output.pdf', attachment_content_type: 'application/pdf')
    _(logo.valid?).must_equal false
    _(logo.errors.size).must_equal 2
    _(logo.errors[:attachment_content_type]).must_equal ['Open Hub accepts GIF, JPG, and PNG formats for logo images.']
  end

  it 'support GIF images' do
    assert_difference 'Logo.count' do
      Logo.create(attachment_file_name: 'imawesome.gif', attachment_content_type: 'image/gif')
    end
  end

  it 'support JPG images' do
    assert_difference 'Logo.count' do
      Logo.create(attachment_file_name: 'imawesome.jpg', attachment_content_type: 'image/jpeg')
    end
  end

  it 'supports PNG images' do
    assert_difference 'Logo.count' do
      Logo.create(attachment_file_name: 'imawesome.png', attachment_content_type: 'image/png')
    end
  end

  it 'invalid empty filename' do
    logo = Logo.new
    _(logo.valid?).must_equal false
    _(logo.errors[:attachment_file_name]).must_equal ['can\'t be blank']
  end

  it 'valid filename' do
    logo = Logo.new(attachment_file_name: 'test.jpg',
                    attachment_content_type: 'image/jpeg', attachment_file_size: '643')
    _(logo).must_be :valid?
    _(logo.errors).must_be :empty?
  end

  it 'invalid file size' do
    logo = Logo.new(attachment_file_name: 'test.jpg',
                    attachment_content_type: 'image/jpeg', attachment_file_size: '6640643')
    _(logo.valid?).must_equal false
    _(logo.errors[:attachment_file_size]).must_equal ['File size is too big (must be less than 500 kB)']
  end

  it 'Logo Upload with wrong URL' do
    logo = Logo.new(url: 'http://123456790notexist.com/ohloh.jpg', attachment_content_type: 'image/jpg')
    logo.save
    _(logo.errors[:url]).must_equal ['Invalid URL / Image not found']
  end

  it 'Logo Upload with wrong file type' do
    logo = Logo.new(url: 'https://www.ohloh.net/robots.txt', attachment_content_type: 'text/plain')
    logo.save
    _(logo.errors[:attachment]).must_equal ['Open Hub accepts GIF, JPG, and PNG formats for logo images.']
  end

  it 'Logo Upload with Huge file size of 5MB' do
    logo = Logo.new(url: 'https://www.ohloh.net/images/clear.gif',
                    attachment_content_type: 'image/gif', attachment_file_size: '5242880')
    logo.save
    _(logo.errors[:attachment_file_size]).must_equal ['File size is too big (must be less than 500 kB)']
  end

  it 'Logo Upload with valid file' do
    VCR.use_cassette('LogoClearGif') do
      logo = Logo.new(url: 'https://www.openhub.net/images/clear.gif',
                      attachment_content_type: 'image/gif')
      logo.save!
      _(logo.errors.size).must_equal 0
      _(File.basename(logo.attachment.url, File.extname(logo.attachment.url))).must_equal 'clear'
      _(logo.attachment.url(:tiny)).must_match 'tiny'
      _(logo.attachment.url(:small)).must_match 'small'
      _(logo.attachment.url(:med)).must_match 'med'
      _(logo.errors.size).must_equal 0
    end
  end

  it 'Project without logo' do
    _(Logo.default_file_name(:tiny)).must_equal 'no_logo_16.png'
    _(Logo.default_file_name(:small)).must_equal 'no_logo_32.png'
    _(Logo.default_file_name(:med)).must_equal 'no_logo.png'
    _(Logo.default_file_name).must_equal 'no_logo.png'
  end
end
