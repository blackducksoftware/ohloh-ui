# frozen_string_literal: true

def code_location_stub(scm_type: :git, url: Faker::Internet.url, branch: :main)
  url = ":pserver:anonymous:@cvs.sourceforge.net:/#{Faker::Lorem.word}/#{Faker::Lorem.word}" if scm_type == :cvs
  CodeLocation.new(url: url, scm_type: scm_type, branch: branch)
end

def code_location_stub_with_id
  code_location = code_location_stub
  code_location.instance_variable_set('@id', Faker::Number.number(4))
  code_location
end

def create_enlistment_with_code_location(project = create(:project), data: {})
  WebMocker.create_code_location
  unmocked_create_enlistment_with_code_location(project, data)
end

def create_enlistment_with_another_code_location(project = create(:project))
  url = 'https://github.com/rails/spring'
  WebMocker.create_another_code_location(url)
  unmocked_create_enlistment_with_code_location(project, {}, url)
end

def unmocked_create_enlistment_with_code_location(project = create(:project), data = {}, url = Faker::Internet.url)
  code_location = CodeLocation.create({ url: url, branch: :main, scm_type: :git,
                                        client_relation_id: project.id }.merge(data))
  WebMocker.get_project_code_locations(true, id: code_location.id)
  create(:enlistment, project: project, code_location_id: code_location.id)
end

def create_random_enlistment(url)
  Enlistment.connection.execute("insert into repositories (type, url) values ('GitRepository', '#{url}')")
  repository_id = Enlistment.connection.execute('select max(id) from repositories').values[0][0]
  execute_string = "insert into code_locations (repository_id, module_branch_name) values (#{repository_id}, 'main')"
  Enlistment.connection.execute(execute_string)
  code_location_id = Enlistment.connection.execute('select max(id) from code_locations').values[0][0]
  create(:enlistment, code_location_id: code_location_id)
end
