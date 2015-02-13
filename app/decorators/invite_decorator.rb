class InviteDecorator < Cherry::Decorator

  def claim_url
    "http://#{URL_HOST}/p/#{object.project_id}/contributors/#{object.contribution_id}?invite=#{object.activation_code}"
  end
end
