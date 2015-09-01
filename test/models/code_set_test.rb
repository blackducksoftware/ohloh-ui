require 'test_helper'

class CodeSetTest < ActiveSupport::TestCase
  let(:repository) { create(:git_repository) }
  let(:code_set) { create(:code_set, repository: repository) }

  describe 'fetch' do
    let(:clump) { create(:git_clump, code_set: code_set) }

    it 'must find existing clump' do
      code_set.stubs(:scm_pull)

      code_set.clump.must_be_nil
      code_set.fetch
      code_set.reload.clump.must_be_instance_of(GitClump)
    end

    it 'must call pull on the scm' do
      clump.scm_class.any_instance.expects(:pull)
      code_set.fetch
    end

    it 'must yield steps correctly' do
      clump.scm_class.class_eval do
        def pull(_scm)
          yield(0, 1)
          yield(1, 1)
        end
      end

      steps = []
      code_set.fetch do |step, max_steps|
        steps << [step, max_steps]
      end

      steps.must_equal [[0, 1], [0, 2], [1, 2], [2, 2]]
    end
  end

  describe 'import' do
    it 'must find or create existing clump' do
      CodeSet::Import.any_instance.stubs(:perform)
      CodeSet.any_instance.expects(:find_or_create_clump)

      code_set.import
    end
  end
end
