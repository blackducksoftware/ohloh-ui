require 'test_helper'

describe 'PrivacyController' do
  it 'should get account privacy page' do
    account = create(:account)
    get :edit, id: account.id
    must_respond_with :ok
  end
end
