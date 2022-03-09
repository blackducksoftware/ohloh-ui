# frozen_string_literal: true

require 'test_helper'

class ActsAsProtected::ActsAsProtectedTest < ActiveSupport::TestCase
  describe '#edit_authorized?' do
    it 'returns false if there is no editor set' do
      _(Project.new.edit_authorized?).must_equal false
    end

    it 'returns true if the editor is an admin' do
      p = create(:project)
      p.editor_account = create(:admin)
      _(p.edit_authorized?).must_equal true
    end

    it 'returns false if editor is not verified' do
      project = create(:project)
      account = create(:account)
      account.verifications.destroy_all

      project.editor_account = account

      _(project).wont_be :edit_authorized?
    end

    it 'returns false if editor is disabled' do
      project = create(:project)
      account = create(:account)

      account.access.spam!
      project.editor_account = account

      _(project).wont_be :edit_authorized?
    end

    it 'returns true if the project is new' do
      p = Project.new
      p.editor_account = create(:account)
      _(p.edit_authorized?).must_equal true
    end

    it 'calls allow_edit? if the object responds to it' do
      p = create(:project)
      p.editor_account = create(:account)
      p.expects(:allow_edit?).returns true
      _(p.edit_authorized?).must_equal true
    end

    it 'allows edits on non-protection enabled objects' do
      p = create(:project)
      p.editor_account = create(:account)
      p.expects(:protection_enabled?).returns false
      _(p.edit_authorized?).must_equal true
    end

    it 'allows edits on protection enabled objects by managers' do
      p = create(:project)
      p.editor_account = create(:account)
      p.stubs(:protection_enabled?).returns true
      p.expects(:aap_authorized_editors).returns [p.editor_account]
      _(p.edit_authorized?).must_equal true
    end

    it 'disallows edits on protection enabled objects by non-managers' do
      p = create(:project)
      p.editor_account = create(:account)
      p.expects(:protection_enabled?).returns true
      p.expects(:aap_authorized_editors).returns [create(:account)]
      _(p.edit_authorized?).must_equal false
    end
  end

  describe '#protection_enabled?' do
    it 'returns false by default for projects' do
      _(create(:project).protection_enabled?).must_equal false
    end

    it 'returns true by default for permissions' do
      _(create(:permission).protection_enabled?).must_equal true
    end

    it 'returns true by default for permissions' do
      Project.any_instance.expects(:protection_enabled?).returns true
      _(create(:enlistment).protection_enabled?).must_equal true
    end
  end

  describe '#must_be_authorized validation' do
    it 'does not fail validations if unchanged (this can happen when adding a protected project to your stack)' do
      proj = create(:project)
      proj.stubs(:edit_authorized?).returns false
      _(proj).must_be :valid?
    end

    it 'fails validations for changed objects if not authorized to change' do
      proj = create(:project)
      proj.name = 'spamspamspam'
      proj.expects(:edit_authorized?).returns false
      _(proj).wont_be :valid?
    end
  end
end
