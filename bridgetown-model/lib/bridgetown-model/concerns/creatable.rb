# frozen_string_literal: true

require "active_support/concern"

module Bridgetown
  module ContentModel::Creatable
    extend ActiveSupport::Concern

    class_methods do
      def wrap_document(document)
        ContentStrategy.klass_for_document(document).new.tap do |model|
          model.wrap_document(document)
        end
      end

      def new_document_to_wrap(label: nil, site: nil)
        label = collection_label if label.nil?
        site = Bridgetown.sites.first if site.nil?

        collection_name = collection_name_for_label(label, site: site)
        if collection_name == "pages"
          Bridgetown::PageWithoutAFile.new(site, site.source, "", "")
        else
          Document.new(nil, collection: site.collections[collection_name])
        end
      end
  
      def collection_name_for_label(label, site:)
        label = label.to_s
        if label == "page"
          "pages"
        elsif label == "pages"
          label
        elsif site.collections[label]
          label
        elsif site.collections[label.pluralize]
          label.pluralize
        else
          raise Errors::FatalException,
                "Collection could not be found for `#{label}'"
        end
      end
    end
  end
end
