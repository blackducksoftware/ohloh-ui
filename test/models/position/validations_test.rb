# frozen_string_literal: true

require 'test_helper'

class Position::ValidationsTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:project) { create(:project) }
  let(:name_obj) { create(:name) }

  describe 'create' do
    it 'must check the existence of given project' do
      position = build(:position, project: nil, project_oss: 'anything', name_id: name_obj.id)

      _(position).wont_be :valid?
      _(position.errors.messages[:project_oss].first).must_equal I18n.t('position.project_id.blank')
    end

    it 'must work with a project_id when no project name is given' do
      position = create_position(project: project, name: name_obj)

      _(position).must_be :persisted?
      _(position.project).must_equal project
    end

    it 'wont allow project title longer than 100 chars' do
      long_string = "#{'0123456789' * 10}a"
      _(long_string.size).must_equal 101

      position = build(:position, name_id: name_obj.id, title: long_string)

      _(position).wont_be :valid?
      _(position.errors.messages[:title].first).must_equal 'is too long (maximum is 100 characters)'
    end

    it 'wont allow description longer than 500 chars' do
      long_string = "#{'0123456789' * 50}a"
      _(long_string.size).must_equal 501

      position = build(:position, name_id: name_obj.id, description: long_string)

      _(position).wont_be :valid?
      _(position.errors.messages[:description].first).must_equal 'is too long (maximum is 500 characters)'
    end

    describe 'start_date' do
      let(:position) { build(:position, name: name_obj) }

      it 'must be present when no committer_name' do
        position = build(:position, start_date: nil, name: nil)

        _(position).wont_be :valid?
        error_message = position.errors.messages[:committer_name].first
        _(error_message).must_equal i18n_activerecord(:position, 'committer_name.blank')
      end

      it 'wont be in the future' do
        position.start_date = 1.day.since
        _(position).wont_be :valid?

        error_message = position.errors.messages[:start_date].first
        _(error_message).must_equal I18n.t('position.start_date.in_future')
      end

      it 'must not ask for start_date when committer_name is present' do
        name_fact = create(:name_fact, analysis: project.best_analysis, name: name_obj)
        position = create :position, committer_name: name_fact.name.name, project: project

        _(position).must_be :persisted?
        _(position.start_date).must_be_nil
      end
    end

    describe 'stop_date' do
      let(:position) { build(:position, name: name_obj) }

      it 'must be present when no committer_name' do
        position = build(:position, stop_date: nil, name: nil)

        _(position).wont_be :valid?
        error_message = position.errors.messages[:committer_name].first
        _(error_message).must_equal i18n_activerecord(:position, 'committer_name.blank')
      end

      it 'wont be in the future' do
        position.stop_date = 1.day.since
        _(position).wont_be :valid?

        error_message = position.errors.messages[:stop_date].first
        _(error_message).must_equal I18n.t('position.stop_date.in_future')
      end

      it 'wont be earlier than start_date' do
        position.start_date = 2.days.ago
        position.stop_date = 3.days.ago
        _(position).wont_be :valid?

        error_message = position.errors.messages[:stop_date].first
        _(error_message).must_equal I18n.t('position.stop_date.earlier')
      end
    end

    describe 'committer_name' do
      it 'wont allow creating a position without a valid committer_name' do
        position = build(:position, committer_name: 'Anything')

        _(position).wont_be :valid?
        _(position.errors.messages[:committer_name].first).must_equal I18n.t('position.no_name_fact')
      end

      it 'wont allow creating a position with a name_fact associated with name but not project' do
        NameFact.create!(name: name_obj)
        position = build(:position, committer_name: name_obj.name)

        _(position).wont_be :valid?
        _(position.errors.messages[:committer_name].first).must_equal I18n.t('position.no_name_fact')
      end
    end
  end

  it 'wont allow duplicate claims from different accounts' do
    Position.delete_all
    project = create(:project)
    name = create(:name)
    john = create(:account, name: :john)
    mary = create(:account, name: :mary)

    NameFact.create!(analysis: project.best_analysis, name: name)

    position = create(:position, account: john, committer_name: name.name, project: project)
    _(position).must_be :persisted?

    new_position = build(:position, account: mary, committer_name: name.name, project: project)
    _(new_position).wont_be :valid?

    error_message = new_position.errors.messages[:committer_name].first
    _(error_message).must_equal I18n.t('position.name_already_claimed', name: john.name)
  end

  it 'must not allow more than one position per project and account' do
    project = create(:project)
    account = create(:account)

    create(:name_fact, analysis: project.best_analysis, name: name_obj)
    create(:position, account: account, name: name_obj, project: project)
    position = build(:position, account: account, name: create(:name), project: project)

    _(position).wont_be :valid?
    _(position.errors[:project_id].first).must_equal i18n_activerecord(:position, 'project_id.taken')
  end
end
