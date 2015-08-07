module Startram
  class Session
    def initialize
      @store = {} of String => String
    end

    forward_missing_to @store
  end
end
