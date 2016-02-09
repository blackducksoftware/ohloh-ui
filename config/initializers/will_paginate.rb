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

if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        alias_method :per, :per_page
        alias_method :num_pages, :total_pages
        alias_method :total_count, :count
      end
    end
  end
end

module BootstrapPagination
  class Rails < WillPaginate::ActionView::LinkRenderer
    def to_html
      ul_element = super
      tag(:div, ul_element, class: 'oh_pagination text-center')
    end
  end
end
