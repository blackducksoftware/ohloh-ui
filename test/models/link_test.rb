require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  it 'must raise an error when no editor' do
    skip 'Integrate alongwith acts_as_editable'
    -> { create(:link) }.must_raise(ActiveRecord::Acts::Editable::MissingEditorError)
  end

  it 'must create a link' do
    link = create(:link, project: projects(:linux))
    projects(:linux).links.must_include link
  end

  it 'must prevent blank url' do
    link = build(:link, url: '')
    link.save
    link.errors.must_include(:url)
  end

  it 'must prevent duplicate url' do
    link = create(:link, project: projects(:linux))
    link.errors.must_be :empty?
    link = build(:link, project: projects(:linux), url: link.url)
    link.save
    link.errors.must_include(:url)
  end

  it 'must revive or create deleted links' do
    link = create(:link, project: projects(:linux))
    link.destroy

    new_title = 'new title'
    new_link = build(:link, url: link.url, project_id: link.project_id,
                            title: new_title, link_category_id: Link::CATEGORIES[:Forums])
    new_link.editor_account = create(:account)

    assert_no_difference('Link.count') do
      new_link.revive_or_create
    end

    deleted_link = Link.find(link)
    deleted_link.title.must_equal new_title
    deleted_link.link_category_id.must_equal Link::CATEGORIES[:Forums]
  end

  it 'must receive or create for new links' do
    new_title = 'new title'
    new_url   = 'http://www.domain.com'
    new_link = build(:link, url: new_url, project: projects(:linux),
                            title: new_title, link_category_id: Link::CATEGORIES[:Forums])
    new_link.editor_account = create(:account)

    assert_difference('Link.count', 1) do
      new_link.revive_or_create.must_equal true
    end

    link = Link.find(new_link)

    link.title.must_equal new_title
    link.url.must_equal new_url
    link.link_category_id.must_equal Link::CATEGORIES[:Forums]
  end

  describe 'explain_yourself' do
    let(:edit) { stub(value: 5, key: 'some_attribute', is_a?: false) }
    let(:link) { Link.new }
    before { link.stubs(:id).returns(1) }

    it 'test value when not property edit' do
      skip('FIXME: Integrate alongwith acts_as_editable')
      information = link.explain_yourself(edit)
      information.must_equal 'Created link 1'
    end

    it 'test value when property edit without link category id' do
      skip('FIXME: Integrate alongwith acts_as_editable')
      edit.stubs(:is_a?).returns(true)
      information = link.explain_yourself(edit)
      information.must_equal "Changed link 1's some_attribute to be '5'"
    end

    it 'test value when property edit with link category id' do
      skip('FIXME: Integrate alongwith acts_as_editable')
      edit = stub(value: Link::CATEGORIES[:Forums], key: 'link_category_id', is_a?: true)
      information = link.explain_yourself(edit)
      information.must_equal "Changed link 1's link_category_id to be 'Forums'"
    end
  end

  it 'test url' do
    # TODO: Uncomment after integrating acts_as_editable.
    # -> { projects(:linux).update(url: 'linux.com') }.must_raise(ActiveRecord::Acts::Editable::MissingEditorError)

    [ # test for basic validity failures.
      'bad url', 'http://\"$', 'ftp://booasd', 'http://',
      'http://;', "http://www.oh.net'", 'http://www.oh.net`'
    ].each do |url|
      link = build(:link, url: url, project: projects(:linux))
      link.save
      link.wont_be :valid?
      link.errors[:url].must_be :present?
    end

    [ # test for basic validity successes.
      'http://www.domain.com', 'https://www.domain.com',
      'http://www.google.com:8080/some/other/path.php', 'http://www.freshvanilla.org:8080/'
    ].each do |url|
      link = build(:link, url: url, project: projects(:linux))
      link.editor_account = create(:account)
      link.save
      link.must_be :valid?
    end
  end
end
