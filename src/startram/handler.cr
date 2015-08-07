module Startram
  abstract class Handler
    abstract def call(context : Context)
  end
end
