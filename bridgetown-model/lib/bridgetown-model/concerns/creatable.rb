# frozen_string_literal: true

require "active_support/concern"

module Bridgetown
  module ContentModelConcerns
    module Creatable
      extend ActiveSupport::Concern

      class_methods do
        def new_with_document(document)
          ContentStrategy.klass_for_document(document).new.tap do |model|
            model.wrap_document(document)
          end
        end
    
        def new_in_collection(collection)
          new_with_document(Document.new(nil, collection: collection))
        end
    
        def new_in_pages(site)
          new_with_document(Bridgetown::PageWithoutAFile.new(site, site.source, "", ""))
        end
    
        def new_via_label(label, site:)
          collection_name = collection_name_for_label(label, site: site)
          if collection_name == "pages"
            new_in_pages site
          else
            new_in_collection site.collections[collection_name]
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
end
