require 'test_helper'

class AccountDecoratorTest < Draper::TestCase
  before do
    Draper::ViewContext.clear!
    @c = create(:language, name: 'c', nice_name: 'C')
    @cpp = create(:language, name: 'cpp', nice_name: 'C++')
    @js = create(:language, name: 'javascript', nice_name: 'Javascript')
    @java = create(:language, name: 'java', nice_name: 'Java')
  end

  let(:admin) { create(:admin) }
  let(:user) { accounts(:user) }

  let(:cbp) do
    [{ 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '6', 'position_id' => '1' },
     { 'month' => Time.parse('2011-01-01 00:00:00'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2012-11-01 00:00:00'), 'commits' => '1', 'position_id' => '1' }]
  end

  let(:symbolized_cbp) do
    [{ month: Time.parse('2010-04-30 20:00:00 -0400'), commits: '1', position_id: '3' },
     { month: Time.parse('2010-04-30 20:00:00 -0400'), commits: '6', position_id: '1' },
     { month: Time.parse('2011-01-01 00:00:00'), commits: '1', position_id: '3' },
     { month: Time.parse('2012-11-01 00:00:00'), commits: '1', position_id: '1' }]
  end

  let(:cbl) do
    [{ 'commits' => 20, 'l_id' => @c.id, 'l_name' => @c.name, 'l_nice_name' => @c.nice_name },
     { 'commits' => 20, 'l_id' => @cpp.id, 'l_name' => @cpp.name, 'l_nice_name' => @cpp.nice_name },
     { 'commits' => 20, 'l_id' => @js.id, 'l_name' => @js.name, 'l_nice_name' => @js.nice_name },
     { 'commits' => 20, 'l_id' => @java.id, 'l_name' => @java.name, 'l_nice_name' => @java.nice_name }]
  end

  let(:symbolized_cbl) do
    [{ commits: 20, l_id: @c.id, l_name: @c.name, l_nice_name: @c.nice_name },
     { commits: 20, l_id: @cpp.id, l_name: @cpp.name, l_nice_name: @cpp.nice_name },
     { commits: 20, l_id: @js.id, l_name: @js.name, l_nice_name: @js.nice_name },
     { commits: 20, l_id: @java.id, l_name: @java.name, l_nice_name: @java.nice_name }]
  end

  let(:sorted_cbl) do
    [['java', { nice_name: 'Java', commits: 20 }],
     ['javascript', { nice_name: 'Javascript', commits: 20 }],
     ['cpp', { nice_name: 'C++', commits: 20 }],
     ['c', { nice_name: 'C', commits: 20 }]]
  end

  describe 'symbolized_commits_by_project' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.symbolized_commits_by_project.must_be_empty
    end

    it 'should return commits_by_project with keys as symbols' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      user.decorate.symbolized_commits_by_project.must_equal symbolized_cbp
    end
  end

  describe 'sorted_commits_by_project' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.sorted_commits_by_project.must_be_empty
    end

    it 'should return sorted commits_by_project data' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      user.decorate.sorted_commits_by_project.must_equal [[1, 7], [3, 2]]
    end
  end

  describe 'symbolized_commits_by_language' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.symbolized_commits_by_language.must_be_empty
    end

    it 'should return commits_by_language with keys as symbols' do
      user.best_vita.vita_fact.update(commits_by_language: cbl)
      user.decorate.symbolized_commits_by_language.must_equal symbolized_cbl
    end
  end

  describe 'sorted_commits_by_language' do
    it 'should return [] when account has no best_vita' do
      admin.decorate.sorted_commits_by_language.must_be_empty
    end

    it 'should return sorted commits_by_language data' do
      user.best_vita.vita_fact.update(commits_by_language: cbl)
      user.decorate.sorted_commits_by_language.must_equal sorted_cbl
    end
  end
end
