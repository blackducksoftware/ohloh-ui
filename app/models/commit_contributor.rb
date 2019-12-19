# frozen_string_literal: true

class CommitContributor < FisBase
  belongs_to :person
  belongs_to :name
  belongs_to :code_set
  belongs_to :project
end
