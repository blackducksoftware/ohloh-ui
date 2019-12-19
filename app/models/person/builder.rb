# frozen_string_literal: true

class Person::Builder
  class << self
    def rebuild_kudos
      Person.logger.info { 'Person.rebuild_kudos(): Begin' }

      Person.find_each(batch_size: 10_000) do |person|
        kudo_score = KudoScore.find_by_account_or_name_and_project(person) ||
                     NilKudoScore.new
        person.update_columns(
          kudo_score: kudo_score.score, kudo_position: kudo_score.position,
          kudo_rank: kudo_score.rank, popularity_factor: person.searchable_factor
        )
      end

      Person.logger.info { 'Person.rebuild_kudos(): Complete' }
    end

    # Fixes up all the (possibly) changed names between an old and new analysis
    # for a project. This could be brute forced by calling
    # rebuild_by_project_id(project.id), but that's very slow and we don't want to
    # do that every time we update an analysis.
    #
    # Instead, we optimize by manually adding new names and removing names that
    # went away.
    def rebuild_for_analysis_matching_names(project)
      before_names = Person.where(project: project).pluck(:name_id)
      after_names = ContributorFact.unclaimed_for_project(project).pluck(:name_id)

      names_to_delete = before_names - after_names
      Person.where(project: project, name: names_to_delete).delete_all

      names_to_create = after_names - before_names
      create_people_from_names(names_to_create, project)

      fix_contributor_fact_associations_to_match_name_id(project)
    end

    private

    def create_people_from_names(names, project)
      names.each do |name|
        person = Person.where(project: project, name: name).first_or_initialize
        person.name_fact_id = ContributorFact.unclaimed_for_project(project).find_by(name: name).id
        person.save!
      end
    end

    # Finally, because we have a new analysis, all of the name_fact_ids have changed. Update them.
    # Deadlock avoidance by ordering
    # The reason the query is complicated that it should is because it attempts to avoid deadlock
    # when multiple processes are updating people table rows by ordering updates by id.
    def fix_contributor_fact_associations_to_match_name_id(project)
      Person.connection.execute <<-SQL
        UPDATE people SET name_fact_id = people_name_facts.name_fact_id
        FROM (
          #{people_with_contributor_facts_for_project(project).to_sql}
        ) AS people_name_facts
        WHERE id = people_name_facts.person_id;
      SQL
    end

    def people_with_contributor_facts_for_project(project)
      Person
        .select(['people.id as person_id', 'name_facts.id as name_fact_id'])
        .joins(:contributor_fact_on_name_id)
        .where(project: project)
        .where('name_facts.analysis_id = ?', project.best_analysis_id)
        .order('people.id')
    end
  end
end
