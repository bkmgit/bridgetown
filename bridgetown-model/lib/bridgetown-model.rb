# frozen_string_literal: true

require "bridgetown-core"
require "bridgetown-core/version"

require "bridgetown-model/hash_with_dot_access"

module Bridgetown
  autoload :AttributeChangeset, "bridgetown-model/attribute_changeset"
  autoload :ContentModel, "bridgetown-model/content_model"
  autoload :ContentModels, "bridgetown-model/content_model_classes"
  autoload :ContentStrategy, "bridgetown-model/content_strategy"

  Document.class_eval do
    def model
      @model ||= ContentModel.wrap_document(self)
    end
  end

  Page.class_eval do
    def model
      @model ||= ContentModel.wrap_document(self)
    end
  end
end
