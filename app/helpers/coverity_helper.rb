# frozen_strong_literal: true

module CoverityHelper

  def get_coverity_data
    @section_title = @project.name + " on Coverity Scan"
    @section_link = "https://scan.coverity.com/projects/" + @project.vanity_url
    doc = get_html
    get_analysis_metrics(doc)
    get_cwe_top_25(doc)
    get_outstanding_defects(doc)
    get_outstanding_versus_fixed(doc)
  end

  private
  def get_html
    browser = Watir::Browser.new(:chrome, headless: true)
    url = 'https://scan.coverity.com/projects/' + @project.vanity_url
    browser.goto(url)
    Nokogiri::HTML(browser.html)
  end

  def get_analysis_metrics(doc)
    node = doc.at('h3:contains("Analysis Metrics per Components")')
    @analysis_metrics_title = node.to_s
    @analysis_metrics = node.next_element.to_s
  end

  def get_cwe_top_25(doc)
    node = doc.at('h3:contains("CWE Top 25 defects")')
    @cwe_top_25_title = node.to_s
    @cwe_top_25 = node.next_element.to_s
  end

  def get_outstanding_defects(doc)
    @outstanding_defects = doc.at('div#chart-1').to_s
  end

  def get_outstanding_versus_fixed(doc)
    @outstanding_versus_fixed = doc.at('div#chart-2').to_s
  end

end
