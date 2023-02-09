# frozen_string_literal: true

class ProjectSbomsController < ApplicationController
  helper ProjectsHelper

  before_action :set_project_or_fail

  def index
    @agent = @project.sboms.pluck(:agent).uniq
    sbom = @project.sboms.where(agent: 'detect_wizard').first&.sbom_data
    get_package_data(sbom)
  end

  def download_json
    project_sbom = @project.sboms.where(agent: params[:agent]).to_json
    filename = "#{@project.name}_#{params[:agent]}.json"
    send_data project_sbom, type: 'application/json;', disposition: "attachment;filename=#{filename}"
  end

  private

  def get_package_data(sbom)
    return if sbom.nil?

    @packages = sbom['reportContent'].first['fileContent']['packages']
                                     .map { |val| val['externalRefs'] }.flatten
                                     .map { |v| v['referenceLocator'] if v['referenceCategory'] != 'OTHER' }.compact
  end
end
