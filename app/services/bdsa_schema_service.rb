# frozen_string_literal: true

class BdsaSchemaService
  include ActionView::Helpers::TranslationHelper

  def initialize(response:, cve_data:, canonical_url:, params:)
    @response = response
    @cve_data = cve_data
    @canonical_url = canonical_url
    @params = params
  end

  def vulnerability_schema_json
    cve_id = extract_cve_id
    schema = vulnerability_schema(cve_id)
    schema['about']['sameAs'] = "https://nvd.nist.gov/vuln/detail/#{cve_id}" if cve_id
    schema.to_json
  end

  def self.landing_page_schema_json(canonical_url:)
    new(response: nil, cve_data: nil, canonical_url: canonical_url, params: nil).landing_page_schema.to_json
  end

  def landing_page_schema
    base_schema('WebSite').merge(landing_page_content)
  end

  private

  def extract_cve_id
    href = @cve_data&.dig('href')
    href&.split('/')&.last
  end

  def base_schema(type)
    { '@context' => 'https://schema.org', '@type' => type }
  end

  def landing_page_content
    { 'name' => t('vulnerabilities.bdsa.index.schema.name'),
      'alternateName' => t('vulnerabilities.bdsa.index.schema.alternate_names'),
      'description' => t('vulnerabilities.bdsa.index.schema.description'),
      'url' => @canonical_url, 'potentialAction' => search_action_schema,
      'provider' => org_schema(:cyrc), 'publisher' => org_schema(:publisher),
      'isAccessibleForFree' => true, 'offers' => offer_schema }
  end

  def vulnerability_schema(cve_id)
    base_schema('TechArticle').merge(vulnerability_content(cve_id)).merge(vulnerability_entities(cve_id))
  end

  def vulnerability_content(cve_id)
    { 'headline' => "#{@params[:id].upcase} - #{@response['title']}",
      'name' => schema_name(cve_id), 'description' => schema_description,
      'datePublished' => @response['publishedDate'], 'dateModified' => @response['lastModifiedDate'],
      'keywords' => keywords(cve_id), 'isAccessibleForFree' => true }
  end

  def vulnerability_entities(cve_id)
    { 'author' => org_schema(:cyrc), 'publisher' => org_schema(:publisher),
      'mainEntityOfPage' => { '@type' => 'WebPage', '@id' => @canonical_url },
      'about' => about_schema(cve_id), 'offers' => offer_schema }
  end

  def schema_name(cve_id)
    name = @params[:id].upcase
    name += " / #{cve_id}" if cve_id
    "#{name} - #{t('vulnerabilities.bdsa.show.schema.report_name')}"
  end

  def schema_description
    desc = @response['description']&.gsub(/<[^>]*>/, '')&.truncate(250)
    prefix = t('vulnerabilities.bdsa.show.schema.description_prefix')
    suffix = t('vulnerabilities.bdsa.show.schema.description_suffix')
    "#{prefix} #{desc} #{suffix} #{t('vulnerabilities.bdsa.shared.sca_name')}."
  end

  def keywords(cve_id)
    base_keywords = t('vulnerabilities.bdsa.show.schema.keywords')
    severity = @response&.dig('cvss3', 'severity')
    ([@params[:id].upcase, cve_id] + base_keywords + [severity]).compact.join(', ')
  end

  def about_schema(cve_id)
    { '@type' => 'Thing', 'name' => t('vulnerabilities.bdsa.shared.security_vulnerability_report'),
      'description' => t('vulnerabilities.bdsa.show.schema.report_description'),
      'identifier' => [@params[:id].upcase, cve_id].compact }
  end

  def org_schema(type)
    prefix = "vulnerabilities.bdsa.shared.#{type}"
    { '@type' => 'Organization', 'name' => t("#{prefix}_name"), 'url' => t("#{prefix}_url") }
  end

  def offer_schema
    { '@type' => 'Offer', 'name' => t('vulnerabilities.bdsa.shared.sca_name'),
      'description' => t('vulnerabilities.bdsa.shared.sca_description'),
      'url' => t('vulnerabilities.bdsa.shared.sca_url') }
  end

  def search_action_schema
    url_template = "#{@canonical_url}/#{t('vulnerabilities.bdsa.index.schema.search_action_template')}"
    { '@type' => 'SearchAction',
      'target' => { '@type' => 'EntryPoint', 'urlTemplate' => url_template },
      'query-input' => t('vulnerabilities.bdsa.index.schema.search_action_input') }
  end
end
