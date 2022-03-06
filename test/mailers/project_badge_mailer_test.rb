# frozen_string_literal: true

require 'test_helper'

describe ProjectBadgeMailer do
  describe '#check_cii_projects' do
    before do
      CiiProject = Struct.new(:id, :name, :homepage_url, :repo_url)
      @cii_projects = (1..3).map do |i|
        CiiProject.new(i, Faker::Lorem.word, "http://#{Faker::Lorem.word}.com",
                       "http://github.com/#{Faker::Lorem.word}/#{Faker::Lorem.word}")
      end
    end

    it 'should send email the cii projects detail' do
      email = ProjectBadgeMailer.check_cii_projects(@cii_projects)
      _(email.to).must_equal ['openhubteam@blackducksoftware.com']
      _(email[:from].value).must_equal 'mailer@openhub.net'
      _(email.subject).must_equal "CII Best Practices Badge - Found #{@cii_projects.size} new projects"
      assert_difference('ActionMailer::Base.deliveries.count', 1) { email.deliver_now }
    end
  end
end
