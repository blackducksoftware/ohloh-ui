require 'test_helper'
require "#{Rails.root}/app/models/acts_as_editable/acts_as_editable.rb"
require "#{Rails.root}/test/mocks/mock_active_record_base"

class MockEditableRecord < MockActiveRecordBase
  acts_as_editable editable_attributes: [],
                   merge_within: 30.minutes,
                   edit_description: :edit_desc_callback

  def edit_desc_callback
  end
end

class ActsAsEditable::ActsAsEditableTest < ActiveSupport::TestCase
  def setup
    @editor_instance = MockEditableRecord.new
  end

  [:save, :create, :update, :update_attributes].each do |method|
    test "#{method} returns false without an editor account" do
      assert !@editor_instance.save
    end

    test "#{method} returns true with an editor account" do
      @editor_instance.editor_account = 1
      assert @editor_instance.save
    end

    test "#{method}! throws without an editor account" do
      assert_raises(ActsAsEditable::NoEditorAccountError) do
        @editor_instance.send "#{method}!"
      end
    end

    test "#{method}! doesn't throw with an editor account" do
      @editor_instance.editor_account = 1
      assert_nothing_raised do
        @editor_instance.send "#{method}!"
      end
    end
  end

  test 'edit_description option should be invoked during save' do
    @editor_instance.editor_account = 1
    @editor_instance.expects(:edit_desc_callback)
    assert @editor_instance.save
  end
end
