# frozen_string_literal: true

require 'test_helper'

class ForumsHelperTest < ActionView::TestCase
  include ForumsHelper

  before do
    Object.any_instance.stubs(:current_user_is_admin?).returns(true)
  end

  let(:forum) { create(:forum) }
  let(:admin) { create(:admin) }
  let(:admin_sidebar) do
    [
      [
        [nil, 'Posts'],
        [:recent, 'Recent Posts', '/posts'],
        [:need_answers, 'Unanswered Posts', '/posts?unanswered=true']
      ],
      [
        [nil, 'Admin'],
        [:new, 'New Forum', '/forums/new']
      ]
    ]
  end

  let(:forum_sidebar) do
    [
      [
        [nil, 'Topics'],
        [:new_topic, 'New Topic', "/forums/#{forum.id}/topics/new"],
        [:forum, forum.name.to_s, "/forums/#{forum.id}"]
      ],
      [
        [nil, 'Posts'],
        [:recent, 'Recent Posts', '/posts'],
        [:need_answers, 'Unanswered Posts', '/posts?unanswered=true']
      ]
    ]
  end

  it 'should return two sections' do
    @forum = forum
    forums_sidebar(@forum).length.must_equal 2
  end

  it 'should return three sections' do
    @forum = forum
    forums_sidebar(@forum).length.must_equal 2
  end

  it 'should return forum menu list' do
    @forum = forum
    forums_sidebar(@forum).must_equal forum_sidebar
  end

  it 'should return admin forum menu list' do
    forums_sidebar(nil).must_equal admin_sidebar
  end
end
