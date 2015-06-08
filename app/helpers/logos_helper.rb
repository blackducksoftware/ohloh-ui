module LogosHelper
  DEFAULT_LOGOS = {
    15_216 => '.Net Library',
    1231   => 'C Library',
    1228   => 'C++ Library',
    15_212 => 'CakePHP Plugin',
    1189   => 'Console App',
    6221   => 'Drupal Module',
    1183   => 'Java Library',
    1534   => 'Javascript Library',
    6236   => 'Perl Module',
    1174   => 'Python Library',
    1180   => 'Ruby Library'
  }

  def default_logos
    logos = Logo.where(id: DEFAULT_LOGOS.keys).to_a
    DEFAULT_LOGOS.map do |key, value|
      [value, logos.find { |l| l.id == key }]
    end
  end
end
