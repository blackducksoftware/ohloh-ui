require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  let(:user) { accounts(:user) }

  let(:cbp) do
    [{ 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '6', 'position_id' => '1' },
     { 'month' => Time.parse('2011-01-01 00:00:00'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2012-11-01 00:00:00'), 'commits' => '1', 'position_id' => '1' }]
  end

  it 'should return claimed persons with their cbp_map and positions_map' do
    user.best_vita.vita_fact.update(commits_by_project: cbp)

    get :index

    must_respond_with :ok
    assigns(:people).length.must_equal 7
    assigns(:cbp_map).length.must_equal 7
    assigns(:positions_map).length.must_equal 2
  end
end
