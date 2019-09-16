# frozen_string_literal: true

require 'test_helper'

class StackDecoratorTest < ActiveSupport::TestCase
  describe '#name' do
    it 'must return stack title when ' do
      stack = create(:stack)
      stack.decorate.name(nil, nil).must_equal stack.title
    end

    it 'must return default message when stack.account is present' do
      stack = create(:stack, title: nil)
      stack.decorate.name(stack.account, nil).must_equal I18n.t('projects.users.default')
    end

    describe 'title is nil' do
      let(:stack) { create(:stack, title: nil) }

      describe 'account is nil' do
        let(:account) { nil }

        it 'must return project name stack when project is present' do
          project = create(:project)
          stack.decorate.name(account, project).must_equal "#{project.name}'s Stack"
        end

        it 'must return unnamed when no project' do
          stack.decorate.name(account, nil).must_equal I18n.t('unnamed')
        end
      end

      describe 'account is not associated' do
        let(:account) { create(:account) }

        it 'must return project name stack when project is present' do
          project = create(:project)
          stack.decorate.name(account, project).must_equal "#{project.name}'s Stack"
        end

        it 'must return unnamed when no project' do
          stack.decorate.name(account, nil).must_equal I18n.t('unnamed')
        end
      end
    end
  end
end
