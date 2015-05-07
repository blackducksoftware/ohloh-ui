require 'test_helper'

describe 'PeopleControllerTest' do
  before do
    Account.destroy_all
    Person.destroy_all
    account = create(:account, id: rand(9999) + 9999) # get well past the fixture data
    best_vita = create(:best_vita, account: account)
    account.update_attributes(best_vita_id: best_vita.id)
    @claimed = create(:person)
    @claimed.update_attributes(id: account.id, account_id: account.id)
    @unclaimed = create(:person)
    @project1 = create(:project)
    @project2 = create(:project)
    create(:name_fact, analysis_id: @project1.best_analysis_id, name_id: @claimed.name.id)
    create(:name_fact, analysis_id: @project2.best_analysis_id, name_id: @claimed.name.id)
  end

  describe 'index' do
    it 'should render the people found' do
      get :index
      must_respond_with :ok
      response.body.must_match @claimed.account.name
      response.body.must_match @unclaimed.name.name
    end
  end
end
