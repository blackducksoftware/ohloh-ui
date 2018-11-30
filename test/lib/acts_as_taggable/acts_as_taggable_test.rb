require 'test_helper'

class ActsAsTaggable::ActsAsTaggableTest < ActiveSupport::TestCase
  it 'tag_list= properly strips out whitespace' do
    project = create(:project)
    project.tag_list = "   foo\t bar \r\n"
    project.tags.count.must_equal 2
    project.tags.pluck(:name).sort.must_equal %w[bar foo]
  end

  it 'tag_list= properly strips out double quotes' do
    project = create(:project)
    project.tag_list = '"real" beef'
    project.tags.count.must_equal 2
    project.tags.pluck(:name).sort.must_equal %w[beef real]
  end

  it 'tag_list= leaves punctuation alone' do
    project = create(:project)
    project.tag_list = 'c++ SHA-224 Google_Apps i18n_(internationalization)'
    project.tags.count.must_equal 4
    project.tags.pluck(:name).sort.must_equal ['Google_Apps', 'SHA-224', 'c++', 'i18n_(internationalization)']
  end

  it 'tag_list generates correct string' do
    project = create(:project)
    create(:tagging, taggable: project, tag: create(:tag, name: 'Ada'))
    project.tag_list.must_equal 'Ada'
  end
end
