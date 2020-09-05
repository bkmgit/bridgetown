# frozen_string_literal: true

module Bridgetown
  module ContentModels
    class Unknown < Bridgetown::ContentModel
    end

    class Page < Bridgetown::ContentModel
    end

    class Post < Bridgetown::ContentModel
    end
  end

  ContentStrategy.add_klass(ContentModels::Page, collection_labeled: :pages)
  ContentStrategy.add_klass(ContentModels::Post, collection_labeled: :posts)
end
