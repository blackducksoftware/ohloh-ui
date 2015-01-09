class Person < ActiveRecord::Base
  # TODO: searchable plugin
  self.primary_key = :id

  include PgSearch
  pg_search_scope :search_by_vector,
    against: :effective_name,
    using: { tsearch: { tsvector_column: 'vector' } },
    ranked_by: ":tsearch*(1+popularity_factor)"

  belongs_to :account
  belongs_to :name
  belongs_to :project
  belongs_to :name_fact
  belongs_to :contributor_fact, foreign_key: :name_fact_id
  has_many :contributions

  validates :account_id, presence: true, unless: :unclaimed_person?
  validates :name_id, uniqueness: { scope: :project_id }, if: :unclaimed_person?
  validates :name_fact_id, presence: true, if: :unclaimed_person?

  before_validation Person::Hooks.new
  after_save TsearchHooks.new

  fix_string_column_encodings!

  alias_attribute :person_name, :effective_name

  class << self
    def find_claimed(opts = {})
      query, sort_by = opts.delete(:q), opts.delete(:sort_by)
      opts[:total_entries] = cached_claimed_count if query.blank?
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
      return cached_unclaimed_count if query.blank?
      unclaimed_people(q: query, find_by: find_by).size
    end

    def cached_claimed_count
      Rails.cache.fetch('person_claimed_count', expires_in: 15.minutes) do
        where.not(account_id: nil).count
      end
    end

    def cached_unclaimed_count
      Rails.cache.fetch('person_unclaimed_count', expires_in: 15.minutes) do
        Person.count('distinct name_id')
      end
    end

    def rebuild_by_project_id(project_id)
      Person.delete_all(project_id: project_id)
      connection.execute("insert into people (select * from people_view where project_id = #{project_id})")
    end

    def cached_count
      Rails.cache.fetch('person_count', expires_in: 5.minutes) do
        Person.count
      end
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

  def searchable_vector
    if account_id
      {
        a: "#{account.name} #{account.login}",
        b: account.akas.to_s.gsub("\n", ' ')
      }
    else
      { a: effective_name }
    end
  end

  def searchable_factor
    0.0
  end

  private

  def unclaimed_person?
    name_id? && project_id?
  end
end
