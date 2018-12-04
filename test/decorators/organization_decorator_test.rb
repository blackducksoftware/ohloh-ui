require 'test_helper'

class OrganizationDecoratorTest < ActiveSupport::TestCase
  let(:linux) { create(:organization, vanity_url: 'linux') }
  let(:sidebar) do
    [
      [
        [:org_summary, 'Organization Summary', '/orgs/linux'],
        [:settings, 'Settings', '/orgs/linux/settings'],
        [:widgets, 'Widgets', '/orgs/linux/widgets']
      ],
      [
        [:code_data, 'Project Portfolio'],
        [:projects, 'Claimed Projects', '/orgs/linux/projects']
      ]
    ]
  end

  it 'should return array of sidebar menus' do
    linux.decorate.sidebar.must_equal sidebar
  end

  describe '#select_options' do
    before do
      create(:organization, name: 'Zumba')
      create(:organization, name: 'Alcatel')
      create(:organization, name: 'Pontac')
    end

    it 'must add unaffiliated as the first option' do
      OrganizationDecorator.select_options.first.must_equal ['Unaffiliated', '']
    end

    it 'must add Other as the last option' do
      OrganizationDecorator.select_options.last.must_equal ['Other', '']
    end

    it 'must return a list of organization name and ids' do
      options = OrganizationDecorator.select_options
      options.shift && options.pop
      _name, id = options.first
      Organization.find(id).must_be :present?
      options.map(&:first).must_equal %w[Alcatel Pontac Zumba]
    end

    it 'must sort organization names by lower name' do
      create(:organization, name: 'zambi')
      create(:organization, name: 'zzzz')
      organization_names = OrganizationDecorator.select_options.map(&:first)
      organization_names.shift && organization_names.pop
      organization_names.must_equal %w[Alcatel Pontac zambi Zumba zzzz]
    end
  end
end
