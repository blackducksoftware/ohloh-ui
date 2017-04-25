require 'test_helper'

describe 'CodeopenhubController' do
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  before do
    @code_subdomain = 'http://code.lvh.me:3000'
  end

  it 'should return discontinued Code Search page for code.openhub.net' do
    visit @code_subdomain
    assert_text 'Code Search is discontinued'
  end

  it 'should return discontinued Code Search page for code subdomain with letter params' do
    url = @code_subdomain + '/foobar'
    visit url
    assert_text 'Code Search is discontinued'
  end

  it 'should return discontinued Code Search page for code subdomain with number params' do
    url = @code_subdomain + '/123'
    visit url
    assert_text 'Code Search is discontinued'
  end

  it 'should return discontinued Code Search page for code subdomain with number and letter params' do
    url = @code_subdomain + '/123foobar'
    visit url
    assert_text 'Code Search is discontinued'
  end

  it 'should return discontinued Code Search page for code subdomain with junk' do
    url = @code_subdomain + '/@#43abjd_junk'
    visit url
    assert_text 'Code Search is discontinued'
  end
end
