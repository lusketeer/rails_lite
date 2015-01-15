module ActionControllerLite
  class Base
    include Helper
    attr_reader :req, :res, :params

    # Setup the controller
    def initialize(req, res, route_params = {})
      @req, @res = req, res
      @already_built_response = false
      @params = Param.new(req, route_params)
    end

    # Helper method to alias @already_built_response
    def already_built_response?
      @already_built_response
    end

    def invoke_action(name)
      self.send(name)
    end

    # Set the response status code and header
    def redirect_to(url)
      raise "Already Redirected" if already_built_response?
      @res.header['location'] = url
      @res.status = 302
      @already_built_response = true
      session.store_session(@res)
    end

    # Populate the response with content.
    # Set the response's content type to the given type.
    # Raise an error if the developer tries to double render.
    def render_content(content, type)
      raise "Already Rendered" if already_built_response?
      @res.content_type = type
      @res.body = content
      @already_built_response = true
      session.store_session(@res)
    end

    def session
      @session ||= Session.new(@req)
    end

    def render(template_name)
      template_path = "app/views/#{view_folder_name}/#{template_name.to_s}.html.erb"
      template_file = File.read(template_path)
      template = ERB.new(template_file)
      content = template.result(binding)
      render_content(content, "text/html")
    end

    def view_folder_name
      temp = self.class.to_s
      temp.slice!("Controller")
      temp.underscore
    end
  end
end
