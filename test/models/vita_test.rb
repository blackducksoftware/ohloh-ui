require 'test_helper'

class VitaTest < ActiveSupport::TestCase
  let(:vita) { create(:vita) }
  let(:vita_with_fact) { create(:best_vita) }

  describe 'vita_fact' do
    it 'should return nil_vita_fact when there is not vita_fact' do
      vita.vita_fact.class.must_equal NilVitaFact
    end

    it 'should return vita_fact when there is vita_fact' do
      vita_with_fact.vita_fact.class.must_equal VitaFact
    end
  end
end
