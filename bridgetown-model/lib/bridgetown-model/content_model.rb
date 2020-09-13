# frozen_string_literal: true

require "base64"
require "active_model"
require "active_support/core_ext/date_time"

module Bridgetown
  class ContentModel
    require "bridgetown-model/concerns/creatable"
    require "bridgetown-model/concerns/editable"
    require "bridgetown-model/concerns/findable"
    require "bridgetown-model/concerns/savable"

    include ActiveModel::Model
    extend ActiveModel::Callbacks
    define_model_callbacks :save, :destroy

    include Creatable
    include Editable
    include Findable
    include Savable

    def initialize(attributes = {})
      @_changeset = AttributeChangeset.new(self)

      super
    end

    def inspect
      "<#{self.class} #{wrapped_document.relative_path} #{attributes}>"
    end

    def wrap_document(document_to_wrap)
      @_document = document_to_wrap
    end

    def wrapped_document
      @_document ||= self.class.new_document_to_wrap
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
        File.stat(absolute_path).mtime
      else
        wrapped_document.site.time
      end
    end

    def destroy
      run_callbacks :destroy do
        if persisted?
          File.delete(absolute_path)
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
                             " #{wrapped_document.relative_path.presence || ("new " + self.class.to_s)}"
      nil
    end

    def fetch(key, default = nil)
      respond_to?(key) ? send(key) : default
    end
  end
end

require "bridgetown-model/content_model_classes"
