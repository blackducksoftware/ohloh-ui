require 'test_helper'

class AnalysisSlocSetTest < ActiveSupport::TestCase
  describe 'for_repository' do
    it 'should return AnalysisSlocSet' do
      create_analysis_sloc_set
      AnalysisSlocSet.for_code_location(@analysis_sloc_set.sloc_set.code_set.code_location_id)
                     .first.must_equal @analysis_sloc_set
    end
  end

  describe 'for_analysis' do
    it 'should return AnalysisSlocSet for analysis' do
      create_analysis_sloc_set
      AnalysisSlocSet.for_analysis(@analysis_sloc_set.analysis_id).first.must_equal @analysis_sloc_set
    end
  end

  describe 'ignore_tuples' do
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
      create_analysis_sloc_set('Disallow: /foo', svn_sync: true)
      code_set = " and fyles.code_set_id = #{@analysis_sloc_set.sloc_set.code_set_id}"
      @analysis_sloc_set.ignore_tuples.must_equal "fyles.name like '/foo%'".concat(code_set)
    end

    it 'should prepend with slash for SvnSyncRepository' do
      create_analysis_sloc_set('Disallow: foo', svn_sync: true)
      code_set = " and fyles.code_set_id = #{@analysis_sloc_set.sloc_set.code_set_id}"
      @analysis_sloc_set.ignore_tuples.must_equal "fyles.name like '/foo%'".concat(code_set)
    end
  end

  private

  def create_analysis_sloc_set(ignore = '', svn_sync: false)
    sloc_set = create(:sloc_set)
    # TODO: Replace this once we remove code_locations table dependency from AnalysisSlocSet.
    Enlistment.connection.execute("insert into code_locations (best_code_set_id)
                                   values (#{sloc_set.code_set_id})")
    code_location_id = Enlistment.connection.execute('select max(id) from code_locations').values[0][0]
    sloc_set.code_set.update_attributes(code_location_id: code_location_id)
    scm_type = svn_sync ? :svn_sync : :git
    sloc_set.code_set.stubs(:code_location).returns(code_location_stub(scm_type: scm_type))
    @analysis_sloc_set = create(:analysis_sloc_set, sloc_set: sloc_set, ignore: ignore)
  end
end
