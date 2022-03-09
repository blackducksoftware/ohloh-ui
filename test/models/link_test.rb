# frozen_string_literal: true

require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  let(:project) { create(:project) }

  it 'must raise an error when no editor' do
    _(-> { create(:link_with_no_editor_account) }).must_raise(ActiveRecord::RecordInvalid)
  end

  it 'must create a link' do
    link = create(:link, project: project)
    _(project.links).must_include link
  end

  it 'must prevent blank url' do
    link = build(:link, url: '')
    link.save
    _(link.errors).must_include(:url)
  end

  it 'must strip url' do
    url = 'http://example.com'
    link = build(:link, url: " #{url} ", project: project)
    link.editor_account = create(:account)
    link.save!

    link.reload
    _(link.url).must_equal url
  end

  it 'must prevent duplicate url' do
    link = create(:link, project: project, link_category_id: Link::CATEGORIES[:Forums])
    _(link.errors).must_be :empty?
    link = build(:link, project: project, url: link.url, link_category_id: Link::CATEGORIES[:Forums])
    link.save
    _(link.errors).must_include(:url)
  end

  it 'must revive or create deleted links' do
    link = create(:link, project: project)
    link.destroy

    new_title = 'new title'
    new_link = build(:link, url: link.url, project_id: link.project_id,
                            title: new_title, link_category_id: Link::CATEGORIES[:Forums])
    new_link.editor_account = create(:account)

    assert_no_difference('Link.count') do
      new_link.revive_or_create
    end

    deleted_link = Link.where(id: link.id).first
    _(deleted_link.title).must_equal new_title
    _(deleted_link.link_category_id).must_equal Link::CATEGORIES[:Forums]
  end

  it 'must receive or create for new links' do
    new_title = 'new title'
    new_url   = 'http://www.domain.com'
    new_link = build(:link, url: new_url, project: project,
                            title: new_title, link_category_id: Link::CATEGORIES[:Forums])
    new_link.editor_account = create(:account)

    assert_difference('Link.count', 1) do
      _(new_link.revive_or_create).must_equal true
    end

    link = Link.where(id: new_link.id).first

    _(link.title).must_equal new_title
    _(link.url).must_equal new_url
    _(link.link_category_id).must_equal Link::CATEGORIES[:Forums]
  end

  it 'must raise an exception when creating without editor_account' do
    _(-> { create(:link_with_no_editor_account) }).must_raise(ActiveRecord::RecordInvalid)
  end

  it 'test url' do
    [ # test for basic validity failures.
      'bad url', 'http://\"$', 'ftp://booasd', 'http://',
      'http://;', "http://www.oh.net'", 'http://www.oh.net`'
    ].each do |url|
      link = build(:link, url: url, project: project)
      link.save
      _(link).wont_be :valid?
      _(link.errors[:url]).must_be :present?
    end

    [ # test for basic validity successes.
      'http://www.domain.com', 'https://www.domain.com',
      'http://www.google.com:8080/some/other/path.php', 'http://www.freshvanilla.org:8080/'
    ].each do |url|
      link = build(:link, url: url, project: project)
      link.editor_account = create(:account)
      link.save
      _(link).must_be :valid?
    end
  end
end
