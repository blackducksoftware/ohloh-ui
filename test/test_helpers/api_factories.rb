def code_location_stub(scm_type: :git, url: Faker::Internet.url, branch: :master)
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
  code_location = CodeLocation.create({ url: url, branch: :master, scm_type: :git,
                                        client_relation_id: project.id }.merge(data))
  WebMocker.get_project_code_locations(true, id: code_location.id)
  create(:enlistment, project: project, code_location_id: code_location.id)
end
