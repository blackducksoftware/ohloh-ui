require 'test_helper'
class ProjectSecuritySetTest < ActiveSupport::TestCase
  it 'should return true for recent vulnerabilities for a security set' do
    release = create(:release)
    create_list(:releases_vulnerability, 10, release: release)
    pss = release.project_security_set
    pss.most_recent_vulnerabilities?.must_equal true
  end
end
