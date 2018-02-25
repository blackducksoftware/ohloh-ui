require 'test_helper'

class Position::HooksTest < ActiveSupport::TestCase
  describe '#transfer_kudos_and_destroy_previous_unclaimed_person' do
    let(:position) { create_position }

    it 'wont update account.person when no unclaimed person for new data' do
      Person.any_instance.expects(:update).never
      name = create(:name)
      create(:name_fact, analysis: position.project.best_analysis, name: name)
      position.update!(name: name)
    end

    it 'wont update account.person when it is not present' do
      Account.any_instance.stubs(:person)
      Person.any_instance.expects(:update).never

      name = create(:name)
      create(:name_fact, analysis: position.project.best_analysis, name: name)
      position.update!(name: name)
    end

    describe 'account.person.kudo_score is absent' do
      it "must transfer unclaimed person's kudos to account.person" do
        position = create_position
        new_name = create(:name)
        kudo_score = 5
        kudo_rank = 3
        kudo_position = 2
        create(:person, project: position.project, name: new_name,
                        kudo_score: kudo_score, kudo_rank: kudo_rank,
                        kudo_position: kudo_position)

        create(:name_fact, analysis: position.project.best_analysis, name: new_name)
        position.update!(name: new_name)

        position.account.person.kudo_score.must_equal kudo_score
        position.account.person.kudo_rank.must_equal kudo_rank
        position.account.person.kudo_position.must_equal kudo_position
      end
    end

    describe 'account.person.kudo_score is present' do
      let(:new_project) { create(:project) }
      let(:name_obj) { create(:name) }
      let(:kudo_score) { 5 }
      let(:kudo_rank) { 3 }
      let(:kudo_position) { 2 }

      before do
        NameFact.create!(analysis: new_project.best_analysis, name: name_obj)
        position.account.person.update!(kudo_score: 4, kudo_rank: 4, kudo_position: 4)
        create(:person, project: new_project, name: name_obj,
                        kudo_score: kudo_score, kudo_rank: kudo_rank,
                        kudo_position: kudo_position)
      end

      it 'must update account.person with maximum kudo_score' do
        position.update!(project: new_project, name: name_obj)

        position.account.person.kudo_score.must_equal kudo_score
      end

      it 'must update account.person with maximum kudo_rank' do
        account_kudo_rank = position.account.person.kudo_rank
        position.update!(project: new_project, name: name_obj)

        position.account.person.kudo_rank.must_equal account_kudo_rank
      end

      it 'must update account.person with minimum kudo_position' do
        position.update!(project: new_project, name: name_obj)

        position.account.person.kudo_position.must_equal kudo_position
      end
    end
  end

  describe 'update' do
    it 'must create new person when name_id changes' do
      position = create_position

      new_name = create(:name)
      create(:name_fact, analysis: position.project.best_analysis, name: new_name)
      assert_difference 'Person.count' do
        position.update!(name: new_name)
      end
    end

    it 'must create new person when project_id changes' do
      position = create_position
      new_project = create(:project)

      create(:name_fact, analysis: new_project.best_analysis, name: position.name)
      assert_difference 'Person.count' do
        position.update!(project: new_project)
      end
    end
  end

  describe 'after_destroy' do
    it 'must unlink any associated kudos' do
      position = create_position
      kudo = create(:kudo, account: position.account, project: position.project, name: position.name)

      position.destroy

      kudo.reload.account_id.must_be_nil
    end

    it 'must invoke account analysis job on create and dstroy' do
      VitaJob.expects(:schedule_account_analysis).twice
      position = create_position
      position.destroy
    end

    describe 'name_facts' do
      it 'wont create an unclaimed person if name has no name_facts' do
        position = create_position
        position.name_facts.destroy_all

        assert_no_difference('Person.count', 'A person should not be created') do
          position.destroy
        end

        Person.find_by(name: position.name, project: position.project).must_be_nil
      end

      it 'must create an unclaimed person if name has name_facts' do
        position = create_position

        assert_difference('Person.count', 1, 'A person should be created') do
          position.destroy
        end

        Person.find_by(name: position.name, project: position.project).must_be :present?
      end
    end

    describe 'alias dependency' do
      let(:account) { create(:account) }
      let(:project) { create(:project) }
      let(:commit_name) { create(:name) }
      let(:preferred_name) { create(:name) }
      let(:position) { create_position(project: project, name: preferred_name, account: account) }

      before { Project.any_instance.stubs(:code_locations).returns([]) }

      it 'must delete associated aliases' do
        create_project_alias(project, commit_name.id, preferred_name.id, account)
        project.aliases.count.must_equal 1

        position.destroy

        project.reload.aliases.count.must_equal 0
      end

      it 'wont delete aliases created by other users' do
        create_project_alias(project, commit_name.id, preferred_name.id, create(:account))
        project.aliases.count.must_equal 1

        position.destroy

        project.reload.aliases.count.must_equal 1
      end

      it 'must delete associated aliases without affecting other aliases' do
        create_project_alias(project, commit_name.id, preferred_name.id, account)
        create_project_alias(project, create(:name).id, preferred_name.id, create(:account))
        project.aliases.count.must_equal 2

        position.destroy

        project.reload.aliases.count.must_equal 1
      end

      it 'wont delete aliases for other names' do
        create_project_alias(project, create(:name).id, commit_name.id, account)
        project.aliases.count.must_equal 1

        position.destroy

        project.reload.aliases.count.must_equal 1
      end

      it 'wont delete aliases for other projects' do
        new_project = create(:project)
        new_position = create_position(project: new_project, name: preferred_name, account: account)
        create_project_alias(project, commit_name.id, preferred_name.id, account)
        project.aliases.count.must_equal 1

        new_position.destroy

        project.reload.aliases.count.must_equal 1
      end

      it "wont delete an alias redone by other account when original's position is destroyed" do
        original_alias = create_project_alias(project, commit_name.id, preferred_name.id, account)
        project.aliases.count.must_equal 1
        position.destroy
        project.reload.aliases.count.must_equal 0

        # The alias is revived by other account.
        original_alias.reload.find_create_edit.redo!(create(:account))
        project.reload.aliases.count.must_equal 1

        # The original account adds the position back,
        position = create_position(project: project, name: preferred_name, account: account)
        # and deletes it again.
        position.destroy

        project.reload.aliases.count.must_equal 1
        project.reload.aliases.first.commit_name.must_equal commit_name
        project.reload.aliases.first.preferred_name.must_equal preferred_name
      end

      it "must delete an alias redone by other account when other's position is destroyed" do
        original_alias = create_project_alias(project, commit_name.id, preferred_name.id, account)
        project.aliases.count.must_equal 1
        position.destroy
        project.reload.aliases.count.must_equal 0

        # The other account creates a position.
        other_account = create(:account)
        other_position = create_position(project: project, name: preferred_name, account: other_account)

        # The alias is revived by other account.
        original_alias.reload.find_create_edit.redo!(other_account)
        project.reload.aliases.count.must_equal 1

        other_position.destroy

        project.reload.aliases.count.must_equal 0
      end
    end
  end

  describe 'after_save' do
    it 'must call account.update_akas' do
      Account.any_instance.expects(:update_akas).once
      VitaJob.expects(:schedule_account_analysis)
      create_position
    end

    it 'must update any affected kudos with position.account_id' do
      position = create_position
      kudo = create_kudo

      position.update(name: kudo.name, project: kudo.project)

      kudo.reload.account_id.must_equal position.account_id
    end

    it 'wont destroy any affected kudos which have the same sender as position.account_id' do
      position = create_position
      kudo = create_kudo(sender: position.account)

      position.update(name: kudo.name, project: kudo.project)

      Kudo.find_by(id: kudo.id).must_be_nil
    end
  end

  describe 'after_update' do
    it 'updating name must delete unclaimed person associated with the new name' do
      # A new position has a name with name_fact.
      position = create_position
      previous_name_id = position.name_id
      project = position.project
      # The person is not created because there are no name_facts.
      position.name_facts.destroy_all

      unclaimed_person = create(:person, project: project)
      create(:name_fact, analysis: position.project.best_analysis, name: unclaimed_person.name)
      assert_difference('Person.count', -1, 'A person should be destroyed but not created') do
        position.update!(name_id: unclaimed_person.name.id)
      end

      Person.find_by(name_id: previous_name_id, project: project).must_be_nil
      Person.find_by(id: unclaimed_person.id).must_be_nil
    end

    it 'replacing name must create an unclaimed person for the older name' do
      position = create_position
      previous_name_id = position.name_id
      project = position.project
      unclaimed_person = create(:person, project: project)
      create(:name_fact, analysis: position.project.best_analysis, name: unclaimed_person.name)

      assert_no_difference('Person.count', 'One person should be created and one should be destroyed') do
        position.update!(name_id: unclaimed_person.name.id)
      end

      Person.find_by(name_id: previous_name_id, project: project).must_be :present?
      Person.find_by(id: unclaimed_person.id).must_be_nil
    end
  end

  private

  def create_project_alias(project, commit_name_id, preferred_name_id, editor_account)
    project.aliases.create!(commit_name_id: commit_name_id, preferred_name_id: preferred_name_id,
                            editor_account: editor_account)
  end

  def create_kudo(attributes = {})
    name = create(:name)
    project = create(:project)
    NameFact.create!(analysis: project.best_analysis, name: name)
    create(:kudo, { name: name, project: project }.merge(attributes))
  end
end
