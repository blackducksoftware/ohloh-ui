require_relative '../test_helper'

class LogoTest < ActiveSupport::TestCase
  test 'class_exists' do
    assert Logo
    assert Logo.new
  end

  test 'invalid_file_type' do
    logo = Logo.create(attachment_file_name: 'output.pdf', attachment_content_type: 'application/pdf')
    assert_equal false, logo.valid?
    assert_equal 2, logo.errors.size
    assert_equal ['Open Hub accepts GIF, JPG, and PNG formats for logo images.'], logo.errors[:attachment_content_type]
  end

  test 'support GIF images' do
    assert_difference 'Logo.count' do
      Logo.create(attachment_file_name: 'imawesome.gif', attachment_content_type: 'image/gif')
    end
  end

  test 'support JPG images' do
    assert_difference 'Logo.count' do
      Logo.create(attachment_file_name: 'imawesome.jpg', attachment_content_type: 'image/jpeg')
    end
  end

  test 'supports PNG images' do
    assert_difference 'Logo.count' do
      Logo.create(attachment_file_name: 'imawesome.png', attachment_content_type: 'image/png')
    end
  end

  test 'invalid empty filename' do
    logo = Logo.new
    assert_equal false, logo.valid?
    assert ['can\'t be blank'], logo.errors[:attachment_file_name]
  end

  test 'valid filename' do
    logo = Logo.new(attachment_file_name: 'test.jpg',
                    attachment_content_type: 'image/jpeg', attachment_file_size: '643')
    assert logo.valid?
    assert logo.errors.empty?
  end

  test 'invalid file size' do
    logo = Logo.new(attachment_file_name: 'test.jpg',
                    attachment_content_type: 'image/jpeg', attachment_file_size: '6640643')
    assert_equal false, logo.valid?
    assert_equal ['File size is too big (must be less than 500 KB)'], logo.errors[:attachment_file_size]
  end

  test 'Logo Upload with wrong URL' do
    logo = Logo.new(url: 'http://123456790notexist.com/ohloh.jpg', attachment_content_type: 'image/jpg')
    logo.save
    assert_equal ['Invalid URL / Image not found'], logo.errors[:url]
  end

  test 'Logo Upload with wrong file type' do
    logo = Logo.new(url: 'https://www.ohloh.net/robots.txt', attachment_content_type: 'text/plain')
    logo.save
    assert_equal ['Open Hub accepts GIF, JPG, and PNG formats for logo images.'], logo.errors[:attachment]
  end

  test 'Logo Upload with Huge file size of 5MB' do
    logo = Logo.new(url: 'https://www.ohloh.net/images/clear.gif',
                    attachment_content_type: 'image/gif', attachment_file_size: '5242880')
    logo.save
    assert_equal ['File size is too big (must be less than 500 KB)'], logo.errors[:attachment_file_size]
  end

  test 'Logo Upload with valid file' do
    logo = Logo.new(url: 'https://www.openhub.net/images/clear.gif',
                    attachment_content_type: 'image/gif')
    logo.save!
    assert_equal 0, logo.errors.size
    assert_equal 'clear', File.basename(logo.attachment.url, File.extname(logo.attachment.url))
    assert_match 'tiny', logo.attachment.url(:tiny)
    assert_match 'small', logo.attachment.url(:small)
    assert_match 'med', logo.attachment.url(:med)
    assert_equal 0, logo.errors.size
  end

  test 'Project without logo' do
    assert_equal 'no_logo_16.png', Logo.default_file_name(:tiny)
    assert_equal 'no_logo_32.png', Logo.default_file_name(:small)
    assert_equal 'no_logo.png', Logo.default_file_name(:med)
    assert_equal 'no_logo.png', Logo.default_file_name
  end
end
