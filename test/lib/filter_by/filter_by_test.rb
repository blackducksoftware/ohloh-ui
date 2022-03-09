# frozen_string_literal: true

require 'test_helper'

describe 'FilterBy' do
  it 'must build a query comparing filterable_by attributes with given string' do
    _(Diff.filter_by('file_name').to_sql).must_match "(lower(fyles.name) like '%file_name%')"
  end
end
