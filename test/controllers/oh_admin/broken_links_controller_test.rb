require 'test_helper'

describe 'OhAdmin::BrokenLinksController' do
  let(:admin) { create(:admin) }

  let(:broken_link) { create(:broken_link) }

  before do
    login_as admin
    broken_link
  end

  it 'should return list of broken links' do
    get :index
    assigns(:broken_links).must_equal [broken_link]
  end

  it 'should delete the broken link' do
    assert_difference('BrokenLink.count', -1) do
      delete :destroy, id: broken_link.id
    end
  end
end
