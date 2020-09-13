# frozen_string_literal: true

require "active_support/concern"

module Bridgetown
  module ContentModel::Editable
    extend ActiveSupport::Concern

    def attributes
      wrapped_document&.data || {}
    end

    def attribute_changes
      @_changeset.changes
    end

    def attribute_will_change!(key)
      @_changeset.will_change!(key)
    end

    def content
      wrapped_document.content
    end

    def content=(new_content)
      wrapped_document.content = new_content
    end

    def processed_front_matter
      if persisted?
        file_contents = File.read(
          absolute_path,
          Utils.merged_file_read_opts(wrapped_document.site, {})
        )
        if wrapped_document.yaml_file?
          yaml_data = SafeYAML.load(file_contents)
        elsif file_match = file_contents.match(Document::YAML_FRONT_MATTER_REGEXP)
          yaml_data = SafeYAML.load(file_match.captures[0])
        else
          raise Errors::FatalException,
                "YAML front matter not found in #{absolute_path}"
        end
        attribute_changes.each do |attr|
          yaml_data[attr.to_s] = send(attr)
        end
        yaml_data.each_key do |key|
          yaml_data.delete(key) unless attributes.key?(key)
        end
        yaml_data
      else
        attributes.to_h.deep_stringify_keys
      end
    end
  end
end
