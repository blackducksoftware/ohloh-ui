# frozen_string_literal: true

require 'test_helper'

class KudosHelperTest < ActionView::TestCase
  include KudosHelper

  describe 'kudos_aka_name' do
    it 'should return kudo name' do
      position = create(:position)
      kudo = create(:kudo, name_id: position.name_id, project_id: position.project_id)
      _(kudos_aka_name(kudo)).must_match kudo.name.name
    end
  end

  it 'kudo_button_target_account returns person account for Contribution' do
    account = Account.new
    person = Person.new
    person.stubs(:account).returns(account)
    contribution = Contribution.new
    contribution.stubs(:person).returns(person)

    assert_equal account, send(:kudo_button_target_account, contribution)
  end
end
