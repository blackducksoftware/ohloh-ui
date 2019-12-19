# frozen_string_literal: true

require 'test_helper'

describe ProjectExperience do
  describe 'project_name=' do
    it 'must set project_id based on project_name' do
      project = create(:project)
      experience = ProjectExperience.new(project_name: project.name)
      experience.project.must_equal project
    end
  end

  describe 'project_name' do
    it 'must return project.name when it is present' do
      project = create(:project)
      experience = ProjectExperience.new(project_name: project.name)
      experience.project_name.must_equal project.name
    end

    it 'must return project_name when no project.name' do
      project_name = Faker::Company.name
      experience = ProjectExperience.new(project_name: project_name)
      experience.project_name.must_equal project_name
    end
  end

  describe 'project_existence' do
    it 'wont be valid when project_name does not relate to a real project' do
      project_name = Faker::Company.name
      experience = ProjectExperience.new(project_name: project_name)

      experience.wont_be :valid?
      error_message = I18n.t('project_experiences.no_matching_project')
      experience.errors.messages[:project].first.must_equal error_message
    end

    it 'must be valid when project_name relates to a real project' do
      project = create(:project)
      experience = ProjectExperience.new(project_name: project.name)
      experience.must_be :valid?
    end

    it 'must be valid when no project_name is passed' do
      experience = ProjectExperience.new
      experience.must_be :valid?
    end
  end
end
