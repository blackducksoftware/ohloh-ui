# frozen_string_literal: true

module LinkAccessors
  extend ActiveSupport::Concern

  included do
    class << self
      def link_accessors(accessors: {})
        accessors.each do |accessor, link_category|
          cache_method = :"cached_#{accessor}_uri"

          send :attr_accessor, :"#{accessor}_is_dirty"
          send :attr_accessor, cache_method

          define_link_getter(accessor, cache_method, link_category)
          define_link_setter(accessor, cache_method, link_category)
        end
      end

      private

      def define_link_getter(accessor, cache_method, link_category)
        define_method accessor do
          cached_uri = send cache_method
          return cached_uri if cached_uri

          link = links.of_category(Link::CATEGORIES[link_category]).first
          link&.url
        end
      end

      def define_link_setter(accessor, cache_method, link_category)
        define_method :"#{accessor}=" do |uri|
          cleaned_uri = String.clean_url(uri)
          cached_uri = send cache_method
          return if !cached_uri.nil? && cleaned_uri == cached_uri

          update_link_uri(accessor, obtain_link(link_category), cleaned_uri, link_category.to_s)
        end
      end
    end

    private

    def update_link_uri(accessor, link, uri, title)
      send :"#{accessor}_is_dirty=", true
      send :"cached_#{accessor}_uri=", uri
      if uri.blank?
        link.editor_account = editor_account
        link.destroy if link.persisted?
      else
        link.assign_attributes(url: uri, title: title, editor_account: editor_account)
        links << link
      end
    end

    def obtain_link(link_category)
      Link.where(project_id: id).of_category(Link::CATEGORIES[link_category]).first_or_initialize
    end
  end
end
