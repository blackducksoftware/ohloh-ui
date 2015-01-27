module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options[:renderer] ||= BootstrapPagination::Rails
      options[:previous_label] = '&larr;'
      options[:next_label] = '&rarr;'
      options[:class] = 'bootstrap_pagination'
      super.try :html_safe
    end
  end
end

module BootstrapPagination
  class Rails < WillPaginate::ActionView::LinkRenderer
    def to_html
      ul_element = super
      tag(:div, ul_element, class: 'oh_pagination text-center')
    end
    protected
      def ul_class
        @options[:class]
      end
  end
end
