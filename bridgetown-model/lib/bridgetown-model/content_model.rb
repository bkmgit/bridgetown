# frozen_string_literal: true

require "base64"
require "active_model"
require "active_support/core_ext/date_time"

require "bridgetown-model/concerns/creatable"
require "bridgetown-model/concerns/editable"
require "bridgetown-model/concerns/findable"
require "bridgetown-model/concerns/savable"

module Bridgetown
  class ContentModel
    include ActiveModel::Model
    extend ActiveModel::Callbacks
    define_model_callbacks :save, :destroy

    include ContentModelConcerns::Creatable
    include ContentModelConcerns::Editable
    include ContentModelConcerns::Findable
    include ContentModelConcerns::Savable

    def initialize(attributes = {})
      super

      @_changeset = AttributeChangeset.new(self)
    end

    def inspect
      "<#{self.class} #{wrapped_document.relative_path} #{attributes}>"
    end

    def wrap_document(document_to_wrap)
      @_document = document_to_wrap
    end

    def wrapped_document
      @_document
    end

    def absolute_path_in_source_dir
      wrapped_document.site.in_source_dir(wrapped_document.path)
    end

    def url
      wrapped_document.url
    end

    def posted_datetime
      if attributes.include?(:date) && date
        date.to_datetime
      elsif matched = File.basename(wrapped_document.path.to_s).match(%r!^[0-9]+-[0-9]+-[0-9]+!)
        matched[0].to_datetime
      elsif persisted?
        File.stat(absolute_path_in_source_dir).mtime
      else
        wrapped_document.site.time
      end
    end

    def destroy
      run_callbacks :destroy do
        if persisted?
          File.delete(absolute_path_in_source_dir)
          wrapped_document.process_absolute_path("")

          true
        end
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      attributes.include?(method_name) || method_name.to_s.end_with?("=") || super
    end

    def method_missing(method_name, *args)
      return attributes[method_name] if attributes.include?(method_name)

      key = method_name.to_s
      if key.end_with?("=")
        attribute_will_change!(key.chop!)
        attributes[key] = args.first
        return attributes[key]
      end

      Bridgetown.logger.warn "key `#{method_name}' not found in attributes for" \
                             " #{wrapped_document.relative_path}"
      nil
    end

    def fetch(key, default = nil)
      respond_to?(key) ? send(key) : default
    end
  end
end

require "bridgetown-model/content_model_classes"
