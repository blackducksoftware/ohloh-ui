xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @activity_facts.size
  xml.items_available @activity_facts.size
  xml.first_item_position 0
  xml.result do
    @activity_facts.each do |fact|
      xml.activity_fact do
        xml.month             xml_date_to_time(fact.month)
        xml.code_added        fact.code_added.to_i
        xml.code_removed      fact.code_removed.to_i
        xml.comments_added    fact.comments_added.to_i
        xml.comments_removed  fact.comments_removed.to_i
        xml.blanks_added      fact.blanks_added.to_i
        xml.blanks_removed    fact.blanks_removed.to_i
        xml.commits           fact.commits.to_i
        xml.contributors      fact.contributors.to_i
      end
    end
  end
end
