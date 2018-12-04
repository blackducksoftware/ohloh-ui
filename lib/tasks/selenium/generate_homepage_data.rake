# Usage:
# rake selenium:prepare_homepage_data

namespace :selenium do
  file :write_data do
    File.open('tmp/homepage_data.yml', 'w+') do |file|
      file.write({ 'homepage' => @data }.to_yaml)
    end
  end

  desc 'Generates test data for home page'
  task prepare_homepage_data: %i[setup billboard most_popular_projects
                                 most_active_projects most_active_contributors write_data]

  task setup: :environment do
    include ActionView::Helpers::TextHelper
    include HomeHelper
    @data = {}
    @home_decorator = HomeDecorator.new
  end

  task billboard: :environment do
    @data['billboard'] = %w[lines_count active_project_count person_count repository_count].map do |attr|
      number_with_delimiter(@home_decorator.send(attr).to_i)
    end
  end

  task most_popular_projects: :environment do
    @data['most_popular_projects'] = {
      'projects' => @home_decorator.most_popular_projects.map(&:name),
      'users' => @home_decorator.most_popular_projects.map do |project|
        pluralize(project_count(project, 'most_popular_projects'), 'user')
      end
    }
  end

  task most_active_projects: :environment do
    @data['most_active_projects'] = {
      'active_projects' => @home_decorator.most_active_projects.map(&:name),
      'commits' => @home_decorator.most_active_projects.map do |project|
        pluralize(project_count(project, 'most_active_projects'), 'commit')
      end
    }
  end

  task most_active_contributors: :environment do
    @data['most_active_contributors'] = {
      'contributors' => @home_decorator.most_active_contributors.map(&:name),
      'contributors_commits' => @home_decorator.most_active_contributors.map do |contributor|
        pluralize(project_count(contributor, 'most_active_contributors'), 'commit')
      end
    }
  end
end
