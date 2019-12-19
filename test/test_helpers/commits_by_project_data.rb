# frozen_string_literal: true

class CommitsByProjectData
  FIRST_POSTION_COMMITS = %w[25 40 28 18 1 8 26 9].freeze
  SECOND_POSTION_COMMITS = %w[4 3].freeze

  def initialize(first_position_id = '1', second_position_id = '2')
    @first_position_id = first_position_id.to_s
    @second_position_id = second_position_id.to_s
  end

  def construct
    data = []
    FIRST_POSTION_COMMITS.each_with_index do |commits, index|
      data << { 'month' => start_date_str(index + 1), 'commits' => commits, 'position_id' => @first_position_id }
    end

    SECOND_POSTION_COMMITS.each_with_index do |commits, index|
      data << { 'month' => start_date_str(index + 7), 'commits' => commits, 'position_id' => @second_position_id }
    end

    data
  end

  private

  def start_date_str(month)
    (Time.current - 6.years + month.months).beginning_of_month.strftime('%Y-%m-01 00:00:00')
  end
end
