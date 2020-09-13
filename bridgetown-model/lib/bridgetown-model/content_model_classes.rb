# frozen_string_literal: true

module Bridgetown
  module ContentModels
    class Unknown < Bridgetown::ContentModel
    end

    class Page < Bridgetown::ContentModel
      collection :pages
    end

    class Post < Bridgetown::ContentModel
      collection :posts
    end
  end
end
