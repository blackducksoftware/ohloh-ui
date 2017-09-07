require 'test_helper'

describe ProjectSecuritySet do
  it 'should return true if most_recent_vulnerabilites? is greater than one' do
    release = create(:release)
    release.vulnerabilities << create(:vulnerability)
    release.project_security_set.most_recent_vulnerabilities?.must_equal true
  end
end