# frozen_string_literal: true

require 'test_helper'

describe ProjectSecuritySet do
  it 'should return true if most_recent_vulnerabilites? is greater than one' do
    release = create(:release)
    release.vulnerabilities << create(:vulnerability)
    _(release.project_security_set.most_recent_vulnerabilities?).must_equal true
  end

  describe '#release_history' do
    let(:release) { create(:release) }

    before do
      release.vulnerabilities << create(:vulnerability, severity: 0)
      release.vulnerabilities << create(:vulnerability, severity: 1)
      release.vulnerabilities << create(:vulnerability, severity: 2)
      release.vulnerabilities << create(:vulnerability, severity: nil)
      release.vulnerabilities << create(:vulnerability, severity: nil)
    end

    it 'should return the count of vulnerabilities with low severity' do
      _(release.project_security_set.release_history.last.low).must_equal 1
    end

    it 'should return the count of vulnerabilities with medium severity' do
      _(release.project_security_set.release_history.last.medium).must_equal 1
    end

    it 'should return the count of vulnerabilities with high severity' do
      _(release.project_security_set.release_history.last.high).must_equal 1
    end

    it 'should return the count of vulnerabilities with null severity' do
      _(release.project_security_set.release_history.last.unknown_severity).must_equal 2
    end
  end
end
