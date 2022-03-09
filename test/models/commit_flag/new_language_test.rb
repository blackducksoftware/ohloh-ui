# frozen_string_literal: true

require 'test_helper'

class CommitFlag::NewLanguageTest < ActiveSupport::TestCase
  it '#language' do
    lang = create(:language)
    cf = create(:commit_flag, type: 'CommitFlag::NewLanguage', data: { language_id: lang.id })
    nl = CommitFlag::NewLanguage.find(cf.id)
    _(nl.language.id).must_equal lang.id
  end

  it '#language_id=' do
    lang = create(:language)
    cf = create(:commit_flag, type: 'CommitFlag::NewLanguage')
    nl = CommitFlag::NewLanguage.find(cf.id)
    nl.language_id = lang.id
    nl.save!
    _(nl.language.id).must_equal lang.id
  end
end
