# frozen_string_literal: true

xml.instruct!
xml.response do
  if @size_facts.blank?
    xml.status 'error'
    xml.message 'Code analysis is not available'
  else
    xml.status 'success'
    xml.items_returned @size_facts.length
    xml.items_available @size_facts.length
    xml.first_item_position 0
    xml.result do
      @size_facts.each do |fact|
        xml.size_fact do
          xml.month         xml_date_to_time(fact.month)
          xml.code          fact.code_total
          xml.comments      fact.comments_total
          xml.blanks        fact.blanks_total
          xml.comment_ratio(fact.comments_total.to_f / (fact.comments_total + fact.code_total))
          xml.commits       fact.commits
          xml.man_months    fact.activity_months
        end
      end
    end
  end
end
