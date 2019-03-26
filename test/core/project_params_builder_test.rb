require 'test_helper'

class ProjectParamsBuilderTest < ActiveSupport::TestCase
  describe 'it will call the project builder after creating valid params' do
    before do
      @license = create(:license, kb_id: "ad705c59-6893-4980-bdbf-0837f1823cc4")
      @editor = Account.find_by(login: 'ohloh_slave')
      @row = {"project_id"=>"585910", "n_customers_12mo"=>"470", "channel_id"=>"8360077",
              "owner_name"=>"kelektiv/node-uuid", "module_branch"=>"master",
              "description"=>"Rigorous implementation of RFC4122 (v1 and v4) UUIDs.",
              "license_set_id"=>"113903536",
              "simple_form"=>{"type":"CONJUNCTIVE",
                              "set":[{"licenseId":"ad705c59-6893-4980-bdbf-0837f1823cc4",
                                      "discoveredAs":"MIT"}]}.to_json }
    end
    it 'should create a project' do
      Project.any_instance.stubs(:save).returns true
      project_builder = ProjectParamsBuilder.new(@editor)
      project_builder.row = @row
      project_builder.build_project
      assert_not_nil project_builder.project
    end

    it 'should change the name of the project if it already exists' do
      project = create(:project, name: 'node-uuid', vanity_url: 'node-uuid',
                                     description: 'Rigorous implementation of RFC4122 (v1 and v4) UUIDs.',
                                     name_at_forge: 'node-uuid')
      project.save

      Project.any_instance.stubs(:save).returns true
      project_builder = ProjectParamsBuilder.new(@editor)
      project_builder.row = @row
      project_builder.build_project
      project_builder.project.name.wont_equal project.name
      project_builder.project.name.must_equal @row['owner_name']
      project_builder.project.vanity_url.must_equal @row['owner_name'].gsub('/', '_')
    end

    it 'should not save the project if it already exists' do
        project = create(:project, name: 'node-uuid', vanity_url: 'node-uuid',
                                       description: 'Rigorous implementation of RFC4122 (v1 and v4) UUIDs.',
                                       owner_at_forge: 'kelektiv', name_at_forge: 'node-uuid')
        project.save

        Project.any_instance.stubs(:save).returns true
        project_builder = ProjectParamsBuilder.new(@editor)
        project_builder.row = @row
        exception = assert_raises StandardError do
            project_builder.build_project
        end
        assert exception.message.include? "project already exists"
      end
  end
end