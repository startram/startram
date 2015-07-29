module Startram
  abstract class Controller < HTTP::Handler
    def call(request : Request)
    end
  end
end
