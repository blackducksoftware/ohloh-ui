# frozen_string_literal: true

module MapHelper
  def map_init(id, zoom = 2)
    map_script_load + map_js_initialization(id, zoom)
  end

  def map_near_stacks_json(project, params)
    accounts = Account.find_by_sql <<-SQL
      SELECT id, latitude, longitude
      FROM (SELECT DISTINCT ON(id) PROJECT_USERS.*, SE.created_at AS stacked_at FROM accounts PROJECT_USERS
        INNER JOIN stacks S ON S.account_id = PROJECT_USERS.id
        INNER JOIN stack_entries SE ON SE.stack_id = S.id AND SE.deleted_at IS NULL
        WHERE SE.project_id = #{project.id}) AS SUB_QUERY
      WHERE latitude IS NOT NULL AND longitude IS NOT NULL
      ORDER BY #{Account.send(:sanitize_sql, map_zoom_stacks_order(params))} LIMIT 50;
    SQL
    { accounts: accounts }.to_json
  end

  def map_near_contributors_json(project, params)
    accounts = Account.find_by_sql <<-SQL
      SELECT A.id, A.latitude, A.longitude
      FROM accounts A
      INNER JOIN positions PO ON PO.account_id = A.id
      INNER JOIN name_facts NF ON NF.vita_id = A.best_vita_id
      WHERE latitude IS NOT NULL AND longitude IS NOT NULL
      AND PO.project_id = #{project.id}
      ORDER BY #{Account.send(:sanitize_sql, map_zoom_contributors_order(params))} LIMIT 50;
    SQL
    { accounts: accounts }.to_json
  end

  private

  def map_script_load
    key = Rails.application.config.google_maps_api_key
    uri = "#{request.ssl? ? 'https' : 'http'}://maps.googleapis.com/maps/api/js?v=3&amp;key=#{key}"
    "<script src='#{uri}' type='text/javascript'></script>"
  end

  def map_js_initialization(id, zoom)
    javascript_tag <<-JSCRIPT
      document.onreadystatechange = function () {
        if (document.readyState == "complete") {
          OH_Map.load('#{id}', 25, 12, 2);
          OH_Map.moveTo(25, 12, #{zoom});
        }
      };
    JSCRIPT
  end

  def map_zoom_stacks_order(params)
    if params[:zoom].to_i < 3
      'stacked_at DESC'
    else
      "@(latitude - #{params[:lat].to_f}) + @(longitude - #{params[:lng].to_f})"
    end
  end

  def map_zoom_contributors_order(params)
    if params[:zoom].to_i < 3
      'NF.commits DESC'
    else
      "@(A.latitude - #{params[:lat].to_f}) + @(A.longitude - #{params[:lng].to_f})"
    end
  end
end
