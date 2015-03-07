module ApiKeyChecks
  def verify_api_key
    return unless request_format == 'xml'
    api_key = ApiKey.in_good_standing.where(key: params[:api_key]).first
    render_unauthorized unless api_key && api_key.may_i_have_another?
  end
end
