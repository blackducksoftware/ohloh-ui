class OrgInfoGraphics < Cherry::Decorator
  def outside_committers
    out_committers_stats = object.outside_committers_stats
    outside_committers_count = out_committers_stats['out_committers'].to_i
    outside_committers_commits_count = out_committers_stats['out_commits'].to_i
    outside_committers_state = outside_committers_count > 0 ? "inactive" : "disabled"
    outside_committers_state = "active" if (@view == :outside_committers)
    { outside_committers_count: outside_committers_count , outside_committers_state: outside_committers_state,
     out_committers_stats: out_committers_stats, outside_committers_commits_count: outside_committers_commits_count }
  end

  def portfolio_projects
    projects_count = object.projects_count
    portfolio_projects_image = projects_count > 0 ? "projects-gray.png" : "projects-ghost.png"
    portfolio_projects_image = "projects-black.png" if @view == :portfolio_projects
    { projects_count: projects_count, portfolio_projects_image: portfolio_projects_image}
  end

  def portfolio_commits
    affiliated_committers_stats = object.affiliated_committers_stats
    aff_commits_count = affiliated_committers_stats['affl_commits'].to_i
    aff_outside_commits_count = affiliated_committers_stats['affl_commits_out'].to_i
    affilated_committers_state = "active" if (@view == :affiliated_committers)
    {aff_commits_count: aff_commits_count, affiliated_committers_stats: affiliated_committers_stats,
     affilated_committers_state: affilated_committers_state, aff_outside_commits_count: aff_outside_commits_count }
    # {aff_commits_count: "200", affiliated_committers_stats: affiliated_committers_stats,
    #  affilated_committers_state: affilated_committers_state, aff_outside_commits_count: aff_outside_commits_count }
  end

  def outside_project_commits
    affiliated_committers_stats = object.affiliated_committers_stats
    aff_outside_commits_count = affiliated_committers_stats['affl_commits_out'].to_i
    out_committers_stats = object.outside_committers_stats
    outside_projects_count = affiliated_committers_stats['affl_projects_out'].to_i
    outside_projects_image = (outside_projects_count > 0) ? "projects-small-gray.png" : "projects-small-ghost.png"
    outside_projects_image = "projects-small-black.png" if (@view == :outside_projects)
    {aff_outside_commits_count: aff_outside_commits_count, affiliated_committers_stats: affiliated_committers_stats,
      outside_projects_count: outside_projects_count, outside_projects_image: outside_projects_image}
  end

  def affiliated_committers
    affilated_committers_state = (object.affiliators_count > 0) ? "inactive" : "disabled"
    affilated_committers_state = "active" if (@view == :affiliated_committers)
  end

  def other_attributes(type, positioning = false)
    out_commits = object.outside_committers_stats['out_commits'].to_i
    affl_commits_out = object.affiliated_committers_stats['affl_commits_out'].to_i
    affl_commits = object.affiliated_committers_stats['affl_commits'].to_i

    maximum_stick_width = 30
    maximum_stick_height = 50
    minimum_stick_width = 5
    minimum_stick_height = 30

    total = out_commits + affl_commits_out + affl_commits

    if eval(type) == 0
      width = minimum_stick_width
      height = minimum_stick_height
    else
      width = [(eval(type) / total.to_f) * maximum_stick_width, minimum_stick_width].max
      height = [(eval(type) / total.to_f) * maximum_stick_height, minimum_stick_height].max
    end
    stroke = eval(type) == 0 ? "none" : ""
    color = eval(type) == 0 ? "#DDDAD9" : "#000"

    if positioning == true
      return {"style" => "padding-top:#{set_height(type, width)}px"}
    else
      return {"tip-height" => "#{height}", "stick-height" => "#{width}", "stroke" => "#{color}",
      "fill-color" => "#{stroke}"}
    end
  end

  def set_height(type, width)
    return case type
              when "affl_commits_out" then 121-((width.to_i*35)/100)
              when "out_commits" then 120- ((width.to_i*35)/100)
            end
  end

  def arrow_attributes(type, direction, width=157)
    {"arrow-direction" => direction, "svg-width"=>width, "border-stroke" => "1.5"}.merge(other_attributes(type))
  end

end
