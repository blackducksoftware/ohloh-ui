# frozen_string_literal: true

class BrokenLink < ApplicationRecord
  belongs_to :link, optional: true

  filterable_by ['broken_links.error']
end
