require 'test_helper'

class KudoScoreTest < ActiveSupport::TestCase
  describe 'find_by_account_or_name_and_project' do
    describe 'person.account_id presence' do
      it 'must try to find kudo_score by account_id' do
        person = stub(account_id: 1)
        KudoScore.expects(:find_by_account_id).once.returns(true)
        KudoScore.find_by_account_or_name_and_project(person)
      end
    end

    describe 'person.account_id absence' do
      it 'must try to find kudo_score by project_id and name_id' do
        person = stub(account_id: nil, name_id: 1, project_id: 1)
        KudoScore.expects(:find_by_project_id_and_name_id).once
        KudoScore.find_by_account_or_name_and_project(person)
      end
    end
  end
end
