# frozen_string_literal: true

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options[:renderer] ||= BootstrapPagination::Rails
      options[:previous_label] = '&larr;'
      options[:next_label] = '&rarr;'
      super.try :html_safe
    end
  end
end

module BootstrapPagination
  class Rails < WillPaginate::ActionView::LinkRenderer
    def to_html
      ul_element = super
      tag(:div, ul_element, class: 'text-center')
    end
  end
end

# frozen_string_literal: true

# Add pagination capabilities to Array objects
class Array
  # Simple paginate method for Array to make it compatible with will_paginate
  def paginate(options = {})
    page = options[:page] || 1
    per_page = options[:per_page] || WillPaginate.per_page
    total = options.fetch(:total_entries) { size }

    WillPaginate::Collection.create(page, per_page, total) do |pager|
      pager.replace slice(pager.offset, pager.per_page)
    end
  end
end
