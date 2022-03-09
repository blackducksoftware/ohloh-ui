# frozen_string_literal: true

require 'test_helper'

class AccountWidgetTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:widget) { AccountWidget.new(account_id: account.id) }

  describe 'title' do
    it 'should return title' do
      _(widget.title).must_equal I18n.t('account_widgets.title')
    end
  end

  describe 'border' do
    it 'should return zero' do
      _(widget.border).must_equal 0
    end
  end

  describe 'account' do
    it 'should return account' do
      _(widget.account).must_equal account
    end
  end

  describe 'rank' do
    it 'should return the account rank' do
      _(widget.rank).must_equal account.kudo_rank
    end
  end

  describe 'kudos' do
    it 'should return the account kudos size' do
      _(widget.kudos).must_equal account.kudos.size
    end
  end

  describe 'create_widgets' do
    it 'should create descendan widgets' do
      widget_classes = [AccountWidget::Detailed, AccountWidget::Rank, AccountWidget::Tiny]
      _(AccountWidget.create_widgets(account.id).map(&:class)).must_equal widget_classes
    end
  end

  describe 'initialize' do
    it 'should raise exception if account is missing' do
      _(proc { AccountWidget.new }).must_raise ArgumentError
    end
  end
end
