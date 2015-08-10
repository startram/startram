class Startram::Handlers::FlashHandler
  def call(context)
    context.flash.set_current_from_session! context.session

    context.next

    context.flash.update_session(context.session)
  end
end
