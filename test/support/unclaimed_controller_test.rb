# frozen_string_literal: true

module UnclaimedControllerTest
  def limit_by_memory_cap(instance, with_query: true)
    original_object_memory_cap = OBJECT_MEMORY_CAP
    limit = UNCLAIMED_TILE_LIMIT + 1
    Object.send(:remove_const, 'OBJECT_MEMORY_CAP')
    Object.const_set('OBJECT_MEMORY_CAP', limit)

    name = instance.create(:name_with_fact)
    name_fact = name.name_facts.first
    instance.create_list(:person, limit + 2, name: name, name_fact: name_fact)

    instance.get :index, params: { query: (name.name if with_query) }
    people = instance.assigns(:unclaimed_people).find { |list| list[0] == name.id }[1]
    yield people, UNCLAIMED_TILE_LIMIT

    Object.send(:remove_const, 'OBJECT_MEMORY_CAP')
    Object.const_set('OBJECT_MEMORY_CAP', original_object_memory_cap)
  end

  module_function :limit_by_memory_cap
end
