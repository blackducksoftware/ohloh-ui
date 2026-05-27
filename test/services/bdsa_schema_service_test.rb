# frozen_string_literal: true

require 'test_helper'

class BdsaSchemaServiceTest < ActiveSupport::TestCase
  describe 'BdsaSchemaService' do
    let(:response) do
      {
        'title' => 'Test Vulnerability',
        'description' => 'A <b>test</b> vulnerability description',
        'publishedDate' => '2023-01-01T00:00:00Z',
        'lastModifiedDate' => '2023-06-01T00:00:00Z',
        'cvss3' => {
          'baseScore' => 7.5,
          'severity' => 'HIGH',
          'temporalMetrics' => { 'score' => 7.0 }
        }
      }
    end

    let(:cve_data) do
      {
        'href' => 'https://nvd.nist.gov/vuln/detail/CVE-2023-1234'
      }
    end

    let(:canonical_url) { 'https://example.com/vulnerabilities/bdsa/BDSA-2023-0001' }
    let(:params) { { id: 'BDSA-2023-0001' } }

    describe '#vulnerability_schema_json' do
      it 'generates valid JSON-LD schema' do
        service = BdsaSchemaService.new(response: response, cve_data: cve_data, canonical_url: canonical_url,
                                        params: params)
        schema_json = service.vulnerability_schema_json
        schema = JSON.parse(schema_json)

        _(schema['@context']).must_equal 'https://schema.org'
        _(schema['@type']).must_equal 'TechArticle'
        _(schema['about']['sameAs']).must_include 'CVE-2023-1234'
      end

      it 'includes CVE data when available' do
        service = BdsaSchemaService.new(response: response, cve_data: cve_data, canonical_url: canonical_url,
                                        params: params)
        schema = JSON.parse(service.vulnerability_schema_json)

        _(schema['keywords']).must_include 'CVE-2023-1234'
      end

      it 'excludes CVE data when not available' do
        service = BdsaSchemaService.new(response: response, cve_data: nil, canonical_url: canonical_url, params: params)
        schema = JSON.parse(service.vulnerability_schema_json)

        _(schema['keywords']).wont_include 'CVE'
      end
    end

    describe '#landing_page_schema_json' do
      it 'generates valid landing page schema' do
        schema_json = BdsaSchemaService.landing_page_schema_json(canonical_url: canonical_url)
        schema = JSON.parse(schema_json)

        _(schema['@context']).must_equal 'https://schema.org'
        _(schema['@type']).must_equal 'WebSite'
        _(schema['url']).must_equal canonical_url
      end

      it 'includes search action schema' do
        schema_json = BdsaSchemaService.landing_page_schema_json(canonical_url: canonical_url)
        schema = JSON.parse(schema_json)

        _(schema['potentialAction']['@type']).must_equal 'SearchAction'
      end
    end

    describe '#vulnerability_schema' do
      it 'builds complete vulnerability schema' do
        service = BdsaSchemaService.new(response: response, cve_data: cve_data, canonical_url: canonical_url,
                                        params: params)
        schema = service.send(:vulnerability_schema, 'CVE-2023-1234')

        _(schema['@type']).must_equal 'TechArticle'
        _(schema['headline']).must_include 'BDSA-2023-0001'
        _(schema['datePublished']).must_equal '2023-01-01T00:00:00Z'
      end
    end

    describe '#schema_description' do
      it 'strips HTML tags from description' do
        service = BdsaSchemaService.new(response: response, cve_data: nil, canonical_url: canonical_url, params: params)
        description = service.send(:schema_description)

        _(description).wont_include '<b>'
        _(description).must_include 'test'
      end

      it 'handles long descriptions' do
        long_response = response.merge('description' => 'A' * 300)
        service = BdsaSchemaService.new(response: long_response, cve_data: nil, canonical_url: canonical_url,
                                        params: params)
        description = service.send(:schema_description)

        _(description).must_include 'A'
      end
    end

    describe '#keywords' do
      it 'includes BDSA ID in keywords' do
        service = BdsaSchemaService.new(response: response, cve_data: nil, canonical_url: canonical_url, params: params)
        keywords = service.send(:keywords, nil)

        _(keywords).must_include 'BDSA-2023-0001'
      end

      it 'includes CVE ID and severity in keywords' do
        service = BdsaSchemaService.new(response: response, cve_data: cve_data, canonical_url: canonical_url,
                                        params: params)
        keywords = service.send(:keywords, 'CVE-2023-1234')

        _(keywords).must_include 'BDSA-2023-0001'
        _(keywords).must_include 'CVE-2023-1234'
        _(keywords).must_include 'HIGH'
      end
    end

    describe '#about_schema' do
      it 'creates about schema with correct type' do
        service = BdsaSchemaService.new(response: response, cve_data: cve_data, canonical_url: canonical_url,
                                        params: params)
        about = service.send(:about_schema, 'CVE-2023-1234')

        _(about['@type']).must_equal 'Thing'
        _(about['identifier']).must_include 'BDSA-2023-0001'
        _(about['identifier']).must_include 'CVE-2023-1234'
      end
    end

    describe '#org_schema' do
      it 'generates organization schema' do
        service = BdsaSchemaService.new(response: response, cve_data: nil, canonical_url: canonical_url, params: params)
        org = service.send(:org_schema, :publisher)

        _(org['@type']).must_equal 'Organization'
        _(org['name']).wont_be_nil
        _(org['url']).wont_be_nil
      end
    end

    describe '#search_action_schema' do
      it 'generates search action without URL template' do
        service = BdsaSchemaService.new(response: response, cve_data: nil, canonical_url: canonical_url, params: params)
        search_action = service.send(:search_action_schema)

        _(search_action['@type']).must_equal 'SearchAction'
        _(search_action['target']['@type']).must_equal 'EntryPoint'
        _(search_action['query-input']).wont_be_nil
      end
    end
  end
end
