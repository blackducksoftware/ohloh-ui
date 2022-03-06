# frozen_string_literal: true

class CommitContributor < FisBase
  belongs_to :person, optional: true
  belongs_to :name, optional: true
  belongs_to :code_set, optional: true
  belongs_to :project, optional: true
end
