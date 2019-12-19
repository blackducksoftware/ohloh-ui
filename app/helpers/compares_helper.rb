# frozen_string_literal: true

module ComparesHelper
  def compare_section(label, opts = {})
    render partial: 'compares/project_section', locals: { label: label, opts: opts }
  end

  def compare_row(label, cell = :no_data, opts = {})
    render partial: 'compares/project_row', locals: { label: label, cell: cell, opts: opts }
  end
end
