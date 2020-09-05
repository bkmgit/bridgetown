# frozen_string_literal: true

require "active_support/concern"

module Bridgetown
  module ContentModelConcerns
    module Findable
      extend ActiveSupport::Concern

      class_methods do
        def find_in_collection(id, collection)
          find_in_group(id, collection.docs)
        end

        def find_in_pages(id, pages)
          find_in_group(id, pages)
        end

        def find_in_group(id, group)
          id = Base64.urlsafe_decode64(id) unless id.include?(".")
          document = group.find { |doc| doc.relative_path == id }
          new_with_document(document) if document
        end

        def group_for_label(label, site:)
          group = collection_name_for_label(label, site: site)
          if group == "pages"
            site.pages
          else
            site.collections[group].docs
          end
        end

        def models_for_label(label, site:)
          group_for_label(label, site: site).map(&:model).select(&:persisted?)
        end

        def find(id, label:, site:)
          find_in_group id, group_for_label(label, site: site)
        end

        def find_all(label, site:, order_by: :posted_datetime, order_direction: :desc)
          models = models_for_label(label, site: site)

          if order_by.to_s == "use_configured"
            models
          else
            begin
              models.sort_by! do |content_model|
                content_model.send(order_by)
              end
            rescue ArgumentError => e
              Bridgetown.logger.warn "Sorting #{label} by #{order_by}, value comparison failed"
              models.sort_by!(&:posted_datetime)
            end
            order_direction.to_s == "desc" ? models.reverse : models
          end
        end
      end
    end
  end
end