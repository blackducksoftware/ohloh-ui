module ExploreHelper
  COMPARE_PROJECT_INPUT_NOS = [0, 1, 2]

  def scale_to(count, nearest = 100)
    i = (count / nearest.to_f).ceil
    (i == 0 ? 1 : i) * nearest
  end

  def compare_project_inputs
    COMPARE_PROJECT_INPUT_NOS.map do |n|
      { type: 'text', name: "project_#{n}", placeholder: t('.enter_project'), id: "project_#{n}",
        class: 'autocompletable', data: { source: '/autocompletes/project' } }
    end
  end
end
