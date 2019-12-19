# frozen_string_literal: true

class CommitsByLanguageData
  DEFAULT_COMMITS_DATA = {
    '3' => { 'name' => 'xml', 'category' => '1', 'nice_name' => 'XML',
             'commits' => { 0 => '8', 1 => '29', 2 => '7', 3 => '2', 6 => '12', 7 => '2' } },
    '17' => { 'name' => 'csharp', 'category' => '0', 'nice_name' => 'C#',
              'commits' => { 0 => '24', 1 => '37', 2 => '27', 3 => '16', 4 => '1', 5 => '8', 6 => '26', 7 => '9' } },
    '12' => { 'name' => 'ruby', 'category' => '0', 'nice_name' => 'Ruby',
              'commits' => { 6 => '2', 7 => '3' } },
    '30' => { 'name' => 'sql', 'category' => '0', 'nice_name' => 'SQL',
              'commits' => { 2 => '1' } },
    '1' => { 'name' => 'html', 'category' => '0', 'nice_name' => 'HTML',
             'commits' => { 1 => '9' } }
  }.freeze

  class << self
    def construct
      data = []
      DEFAULT_COMMITS_DATA.each do |key, value|
        language_values = { 'l_id' => key, 'l_name' => value['name'], 'l_category' => value['category'],
                            'l_nice_name' => value['nice_name'] }
        value['commits'].each do |k, v|
          data << language_values.merge('month' => (start_date + k.month).to_s, 'commits' => v)
        end
      end

      data
    end

    def sorted
      [
        ['csharp', { nice_name: 'C#', commits: 148 }], ['xml', { nice_name: 'XML', commits: 60 }],
        ['html', { nice_name: 'HTML', commits: 9 }], ['ruby', { nice_name: 'Ruby', commits: 5 }],
        ['sql', { nice_name: 'SQL', commits: 1 }]
      ]
    end

    private

    def start_date
      (Date.current - 6.years).beginning_of_month
    end
  end
end
