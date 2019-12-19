# frozen_string_literal: true

require_relative '../test_helper'

class LogoTest < ActiveSupport::TestCase
  it 'class_exists' do
    Logo.must_be :present?
    Logo.new.must_be :present?
  end

  it 'invalid_file_type' do
    logo = Logo.create(attachment_file_name: 'output.pdf', attachment_content_type: 'application/pdf')
    logo.valid?.must_equal false
    logo.errors.size.must_equal 2
    logo.errors[:attachment_content_type].must_equal ['Open Hub accepts GIF, JPG, and PNG formats for logo images.']
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
    logo.valid?.must_equal false
    logo.errors[:attachment_file_name].must_equal ['can\'t be blank']
  end

  it 'valid filename' do
    logo = Logo.new(attachment_file_name: 'test.jpg',
                    attachment_content_type: 'image/jpeg', attachment_file_size: '643')
    logo.must_be :valid?
    logo.errors.must_be :empty?
  end

  it 'invalid file size' do
    logo = Logo.new(attachment_file_name: 'test.jpg',
                    attachment_content_type: 'image/jpeg', attachment_file_size: '6640643')
    logo.valid?.must_equal false
    logo.errors[:attachment_file_size].must_equal ['File size is too big (must be less than 500 kB)']
  end

  it 'Logo Upload with wrong URL' do
    logo = Logo.new(url: 'http://123456790notexist.com/ohloh.jpg', attachment_content_type: 'image/jpg')
    logo.save
    logo.errors[:url].must_equal ['Invalid URL / Image not found']
  end

  it 'Logo Upload with wrong file type' do
    logo = Logo.new(url: 'https://www.ohloh.net/robots.txt', attachment_content_type: 'text/plain')
    logo.save
    logo.errors[:attachment].must_equal ['Open Hub accepts GIF, JPG, and PNG formats for logo images.']
  end

  it 'Logo Upload with Huge file size of 5MB' do
    logo = Logo.new(url: 'https://www.ohloh.net/images/clear.gif',
                    attachment_content_type: 'image/gif', attachment_file_size: '5242880')
    logo.save
    logo.errors[:attachment_file_size].must_equal ['File size is too big (must be less than 500 kB)']
  end

  it 'Logo Upload with valid file' do
    VCR.use_cassette('LogoClearGif') do
      logo = Logo.new(url: 'https://www.openhub.net/images/clear.gif',
                      attachment_content_type: 'image/gif')
      logo.save!
      logo.errors.size.must_equal 0
      File.basename(logo.attachment.url, File.extname(logo.attachment.url)).must_equal 'clear'
      logo.attachment.url(:tiny).must_match 'tiny'
      logo.attachment.url(:small).must_match 'small'
      logo.attachment.url(:med).must_match 'med'
      logo.errors.size.must_equal 0
    end
  end

  it 'Project without logo' do
    Logo.default_file_name(:tiny).must_equal 'no_logo_16.png'
    Logo.default_file_name(:small).must_equal 'no_logo_32.png'
    Logo.default_file_name(:med).must_equal 'no_logo.png'
    Logo.default_file_name.must_equal 'no_logo.png'
  end
end
