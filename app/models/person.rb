class Person < ActiveRecord::Base
  self.primary_key = :id
  self.per_page = 10

  include PgSearch
  pg_search_scope :search_by_vector,
                  against: :vector,
                  using: { tsearch: { tsvector_column: 'vector' } },
                  ranked_by: ':tsearch*(1+popularity_factor)'

  belongs_to :account
  belongs_to :name
  belongs_to :project
  belongs_to :name_fact
  belongs_to :contributor_fact, foreign_key: :name_fact_id
  belongs_to :contributor_fact_on_name_id, primary_key: :name_id, foreign_key: :name_id, class_name: :ContributorFact
  has_many :contributions

  validates :account_id, presence: true, unless: :unclaimed_person?
  validates :name_id, uniqueness: { scope: :project_id }, if: :unclaimed_person?
  validates :name_fact_id, presence: true, if: :unclaimed_person?

  before_validation Person::Hooks.new
  after_save TsearchHooks.new

  fix_string_column_encodings!

  alias_attribute :person_name, :effective_name

  # FIXME: Move to analysis backend.
  def searchable_factor
    return 0.0 if kudo_position.nil? || Person.count == 1
    num = (Person.count - kudo_position).to_f
    denum = (Person.count - 1).to_f

    # unclaimed contributor tweak - demote them significantly
    num /= 10 unless account_id

    num / denum
  end

  class << self
    def find_claimed(opts = {})
      query, sort_by = opts.delete(:q), opts.delete(:sort_by)
      opts[:total_entries] = Person::Cached.claimed_count if query.blank?
      opts = opts.reverse_merge(page: 1, per_page: 10)

      search_by_vector_or_scoped(query)
        .includes(:account)
        .where.not(account_id: nil)
        .references(:all)
        .sort_by_kudo_position_or_effective_name(query, sort_by)
        .paginate(opts)
    end

    def find_unclaimed(opts = {})
      limit = opts.fetch(:per_page, 10)

      people = includes([:project, :name, name_fact: :primary_language])
               .where(name_id: limit(limit).unclaimed_people(opts))
               .references(:all)

      group_and_sort_by_kudo_positions_or_effective_name(people)
    end

    def count_unclaimed(query = nil, find_by = nil)
      return Person::Cached.unclaimed_count if query.blank?
      unclaimed_people(q: query, find_by: find_by).size
    end

    def rebuild_by_project_id(project_id)
      project_id = Person.send :sanitize_sql, project_id.to_s
      Person.delete_all(project_id: project_id)
      connection.execute("insert into people (select * from people_view where project_id = #{project_id})")
    end

    def unclaimed_people(opts)
      where.not(name_id: nil)
        .find_by_name_or_email(opts)
        .group([:name_id, :effective_name])
        .reorder('MIN(COALESCE(kudo_position,999999999)), lower(effective_name)')
        .pluck(:name_id)
    end

    def search_by_vector_or_scoped(query)
      return where('') if query.blank?
      search_by_vector(query)
    end

    def find_by_name_or_email(opts)
      return where("name_facts.email_address_ids && (#{EmailAddress.search_sql(opts[:q])})")
        .joins(:contributor_fact) if opts[:find_by].eql?('email')

      search_by_vector_or_scoped(opts[:q])
    end

    def sort_by_kudo_position_or_effective_name(query, sort_by)
      return order('') if sort_by.blank? && query.present?
      return reorder(popularity_factor: :desc) if sort_by.blank?
      reorder(sort_by.eql?('kudo_position') ? 'kudo_position NULLs last' : 'lower(effective_name)')
    end

    private

    def group_and_sort_by_kudo_positions_or_effective_name(people)
      people = people.group_by(&:name_id)

      people.sort_by do |_name_id, persons|
        [persons.map(&:kudo_position).compact.min || 999_999_999, persons.first.effective_name.downcase]
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def searchable_vector
    # this function allow us to assign weight value to vector column. 'a' has highest weigtage followed by b,c and d
    return { a: effective_name } if account_id.blank?

    projects_name = Project.where(id: account.positions.pluck(:project_id)).pluck(:name).join(' ')
    {
      a: "#{account.name} #{account.login}",
      b: account.akas.to_s.gsub("\n", ' '),
      d: "#{account.markup.try(:formatted)} #{projects_name}"
    }
  end
  # rubocop:enable Metrics/AbcSize

  private

  def unclaimed_person?
    name_id? && project_id?
  end
end
