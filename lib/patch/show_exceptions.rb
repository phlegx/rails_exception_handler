# This patch enables the exception handler to catch routing errors
module ActionDispatch
  class ShowExceptions
    private
      def render_exception_with_template(env, exception)
        if(RailsExceptionHandler.configuration.environments.include?(Rails.env.to_sym))
          RailsExceptionHandler::Handler.new(env, exception).handle_exception
        else
          raise 'RailsExceptionHandler: This patch should not have been loaded'
        end
      end
      alias_method_chain :render_exception, :template
  end
end
