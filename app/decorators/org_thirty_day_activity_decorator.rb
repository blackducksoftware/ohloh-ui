# frozen_string_literal: true

class OrgThirtyDayActivityDecorator < Cherry::Decorator
  delegate :project_count, to: :@object

  def project_count_text
    case project_count
    when 1..10 then 'S'
    when 11..50 then 'M'
    when 51..1000 then 'L'
    else
      'N/A'
    end
  end
end
