# Encapsulate loading the resource indicated in the URL.

module ResourceLoading
  def self.included(controller)
    controller.extend ClassMethods
  end

  module ClassMethods
    # A convenience class method to set up a before action
    def load_resource(method_name, **opts)
      before_action -> { load_resource(method_name) }, **opts
    end
  end

  private

  # Loads the 'Resource' the URL is 'Locating'
  def load_resource(method_name)
    send(method_name) or render_404
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def render_404
    render status: :not_found, json: {
      errors: [
        {
          status: '404',
          title: 'Not Found',
          detail: "The requested resource at #{request.path} could not be found.",
        },
      ],
    }
  end
end
