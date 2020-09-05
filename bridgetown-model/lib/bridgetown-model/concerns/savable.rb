# frozen_string_literal: true

require "active_support/concern"

module Bridgetown
  module ContentModelConcerns
    module Savable
      extend ActiveSupport::Concern

      def id
        return nil unless persisted?

        Base64.urlsafe_encode64(wrapped_document.relative_path, padding: false)
      end

      def persisted?
        wrapped_document.path.present? && File.exist?(absolute_path_in_source_dir)
      end

      def generate_new_slug
        prefix = if wrapped_document.respond_to?(:collection) &&
            wrapped_document.collection.label == "posts"
                   wrapped_document.date.to_datetime.strftime("%Y-%m-%d-")
                 else
                   ""
                 end
  
        # TODO: allow the new file extension to be customizable
        prefix + if respond_to?(:title)
                   Utils.slugify(title.to_s) + ".md"
                 elsif respond_to?(:name)
                   Utils.slugify(name.to_s) + ".md"
                 else
                   "untitled-#{Time.now.to_i}.md"
                 end
      end
  
      def file_output_to_write
        if wrapped_document.yaml_file?
          processed_front_matter.to_yaml
        else
          processed_front_matter.to_yaml + "---" + "\n\n" + content.to_s
        end
      end

      def save
        content_dir = if wrapped_document.respond_to? :collection
                        collection = wrapped_document.collection
                        collection.directory
                      else
                        wrapped_document.site.source
                      end
  
        run_callbacks :save do
          if wrapped_document.path.blank?
            wrapped_document.process_absolute_path(
              File.join(
                content_dir,
                generate_new_slug
              )
            )
          end
  
          # Create folders if necessary
          dir = File.dirname(absolute_path_in_source_dir)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
  
          File.open(absolute_path_in_source_dir, "w") do |f|
            f.write(file_output_to_write)
          end
  
          @_changeset.clear!
  
          true
        end
      end
    end
  end
end
