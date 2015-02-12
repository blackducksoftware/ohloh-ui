def start_date_str(month = 0)
  (Time.now - 6.years + month.months).beginning_of_month.strftime('%Y-%m-01 00:00:00')
end

def start_date
  (Date.today - 6.years).beginning_of_month
end

FactoryGirl.define do
  factory :name_fact do
    association :analysis
    association :name
    association :primary_language, factory: :language
    type 'ContributorFact'
  end

  factory :vita_fact do
    association :analysis
    association :name
    association :primary_language, factory: :language
    type 'VitaFact'
    first_checkin Time.now - 3.days
    last_checkin Time.now - 1.day
    commits_by_project [{ 'month' => start_date_str, 'commits' => '25', 'position_id' => '1' },
                        { 'month' => start_date_str(1), 'commits' => '40', 'position_id' => '1' },
                        { 'month' => start_date_str(2), 'commits' => '28', 'position_id' => '1' },
                        { 'month' => start_date_str(3), 'commits' => '18', 'position_id' => '1' },
                        { 'month' => start_date_str(4), 'commits' => '1', 'position_id' => '1' },
                        { 'month' => start_date_str(5), 'commits' => '8', 'position_id' => '1' },
                        { 'month' => start_date_str(6), 'commits' => '26', 'position_id' => '1' },
                        { 'month' => start_date_str(6), 'commits' => '4', 'position_id' => '2' },
                        { 'month' => start_date_str(7), 'commits' => '9', 'position_id' => '1' },
                        { 'month' => start_date_str(7), 'commits' => '3', 'position_id' => '2' }]
    commits_by_language [{ 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
                           'month' => start_date.to_s, 'commits' => '8' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => start_date.to_s, 'commits' => '24' },
                         { 'l_id' => '1', 'l_name' => 'html', 'l_category' => '1', 'l_nice_name' => 'HTML',
                           'month' => (start_date + 1.month).to_s, 'commits' => '9' },
                         { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
                           'month' => (start_date + 1.month).to_s, 'commits' => '29' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 1.month).to_s, 'commits' => '37' },
                         { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
                           'month' => (start_date + 2.months).to_s, 'commits' => '7' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 2.months).to_s, 'commits' => '27' },
                         { 'l_id' => '30', 'l_name' => 'sql', 'l_category' => '0', 'l_nice_name' => 'SQL',
                           'month' => (start_date + 2.months).to_s, 'commits' => '1' },
                         { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
                           'month' => (start_date + 3.months).to_s, 'commits' => '2' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 3.months).to_s, 'commits' => '16' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 4.months).to_s, 'commits' => '1' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 5.months).to_s, 'commits' => '8' },
                         { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
                           'month' => (start_date + 6.months).to_s, 'commits' => '12' },
                         { 'l_id' => '12', 'l_name' => 'ruby', 'l_category' => '0', 'l_nice_name' => 'Ruby',
                           'month' => (start_date + 6.months).to_s, 'commits' => '2' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 6.months).to_s, 'commits' => '26' },
                         { 'l_id' => '3', 'l_name' => 'xml', 'l_category' => '1', 'l_nice_name' => 'XML',
                           'month' => (start_date + 7.months).to_s, 'commits' => '2' },
                         { 'l_id' => '12', 'l_name' => 'ruby', 'l_category' => '0', 'l_nice_name' => 'Ruby',
                           'month' => (start_date + 7.months).to_s, 'commits' => '3' },
                         { 'l_id' => '17', 'l_name' => 'csharp', 'l_category' => '0', 'l_nice_name' => 'C#',
                           'month' => (start_date + 7.months).to_s, 'commits' => '9' }]
  end
end
