require 'test_helper'

describe 'PrivacyController' do
  it 'should get account privacy page' do
    account = create(:account)
    get :edit, id: account.id
    must_respond_with :ok
  end

  describe 'update' do
    let(:account) { accounts(:user) }

    it 'should update email master to false' do
      put :update, id: account.id, account: { email_master: false }
      account.save!
      account.reload
      account.email_master.must_equal false
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email master to true if set to false' do
      account.email_master = false
      put :update, id: account.id, account: { email_master: true }
      account.reload
      account.email_master.must_equal true
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email kudos to false' do
      put :update, id: account.id, account: { email_kudos: false }
      account.save!
      account.reload
      account.email_kudos.must_equal false
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email kudos to true if set to false' do
      account.email_kudos = false
      put :update, id: account.id, account: { email_kudos: true }
      account.reload
      account.email_kudos.must_equal true
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email posts to false' do
      put :update, id: account.id, account: { email_posts: false }
      account.save!
      account.reload
      account.email_posts.must_equal false
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email posts to true if set to false' do
      account.email_posts = false
      put :update, id: account.id, account: { email_posts: true }
      account.reload
      account.email_posts.must_equal true
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end
  end
end
