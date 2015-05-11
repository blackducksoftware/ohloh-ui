class LanguageDecorator
  include ColorsHelper

  def initialize(options)
    @options = options
    @series = YAML.load_file(Rails.root.join('config/charting/language.yml'))
  end

  def data
    set_start_date
    Language.from_param(@options[:language_name]).each do |language|
      @series['series'] << { data: LanguageFact.report(language, @options).map(&:percent),
                             color: "##{language_color(language.name)}",
                             name: language.nice_name
      }
    end
    @series
  end

  private

  def set_start_date
    @series['plotOptions']['series']['pointStart'] = Time.now.years_ago(10).to_f * 1000
  end
end
