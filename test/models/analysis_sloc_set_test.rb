require 'test_helper'

class AnalysisSlocSetTest < ActiveSupport::TestCase
  describe 'for_repository' do
    it 'should return AnalysisSlocSet' do
      create_analysis_sloc_set
      AnalysisSlocSet.for_repository(@analysis_sloc_set.sloc_set.repository.id).first.must_equal @analysis_sloc_set
    end
  end

  describe 'for_analysis' do
    it 'should return AnalysisSlocSet for analysis' do
      create_analysis_sloc_set
      AnalysisSlocSet.for_analysis(@analysis_sloc_set.analysis_id).first.must_equal @analysis_sloc_set
    end
  end

  describe 'ignore_tuples' do
    let(:source_scm_class) { SvnSyncRepository.new.source_scm_class }

    before do
      source_scm_class.any_instance.stubs(:validate_server_connection)
      source_scm_class.any_instance.stubs(:restrict_url_to_trunk).returns(Faker::Internet.url)
    end

    it 'should return parsed file names' do
      create_analysis_sloc_set('Disallow: foo.txt')
      code_set = " and fyles.code_set_id = #{@analysis_sloc_set.sloc_set.code_set_id}"
      @analysis_sloc_set.ignore_tuples.must_equal "fyles.name like 'foo.txt%'".concat(code_set)
    end

    it 'should remove prepend slash for directory' do
      create_analysis_sloc_set('Disallow: /foo')
      code_set = " and fyles.code_set_id = #{@analysis_sloc_set.sloc_set.code_set_id}"
      @analysis_sloc_set.ignore_tuples.must_equal "fyles.name like 'foo%'".concat(code_set)
    end

    it 'should leave prepend slash for SvnSyncRepository' do
      create_svn_sync_repository('Disallow: /foo')
      code_set = " and fyles.code_set_id = #{@analysis_sloc_set.sloc_set.code_set_id}"
      @analysis_sloc_set.ignore_tuples.must_equal "fyles.name like '/foo%'".concat(code_set)
    end

    it 'should prepend with slash for SvnSyncRepository' do
      create_svn_sync_repository('Disallow: foo')
      code_set = " and fyles.code_set_id = #{@analysis_sloc_set.sloc_set.code_set_id}"
      @analysis_sloc_set.ignore_tuples.must_equal "fyles.name like '/foo%'".concat(code_set)
    end
  end

  private

  def create_analysis_sloc_set(ignore = '')
    sloc_set = create(:sloc_set)
    repository = create(:repository, best_code_set_id: sloc_set.code_set_id)
    sloc_set.code_set.update_attributes(repository_id: repository.id)
    @analysis_sloc_set = create(:analysis_sloc_set, sloc_set: sloc_set, ignore: ignore)
  end

  def create_svn_sync_repository(ignore = '')
    repository = create(:svn_sync_repository)
    code_set = create(:code_set, repository: repository)
    sloc_set = create(:sloc_set, code_set: code_set)
    @analysis_sloc_set = create(:analysis_sloc_set, sloc_set: sloc_set, ignore: ignore)
  end
end
