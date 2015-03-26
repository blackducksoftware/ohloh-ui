class ResolveUrlNamesController < ApplicationController
  def project
    object_json(Project)
  end

  def organization
    object_json(Organization)
  end

  private

  def object_json(klass)
    query = params[:q].to_s
    object = klass.case_insensitive_url_name(query).first
    render text: (object ? object.attributes : { id: nil }).merge(q: query).to_json
  end
end
