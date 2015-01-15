# require 'active_support/inflector'
module ActionDispatchLite
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern, @http_method, @controller_class, @action_name = pattern, http_method.to_s.downcase, controller_class, action_name
    end

    # checks if pattern matches path and method matches request method
    def matches?(req)
      pattern_match = !!( req.path =~ @pattern )
      method_match = ( req.request_method.to_s.downcase == @http_method )
      pattern_match && method_match
    end

    # use pattern to pull out route params (save for later?)
    # instantiate controller and call controller action
    def run(req, res)
      route_params = retrieve_route_params(req)
      @controller_class.new(req, res, route_params).invoke_action(@action_name)
    end

    def retrieve_route_params(req)
      route_params = {}
      match_data = @pattern.match(req.path)
      unless match_data.nil?
        match_data.names.each do |name|
          route_params[name.to_sym] = match_data[name]
        end
      end
      route_params
    end
  end

  class Router
    METHODS = {
      index:    :get,
      show:     :get,
      new:      :get,
      create:   :post,
      edit:     :get,
      update:   :patch,
      destroy:  :delete
    }
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      self.instance_eval(&proc)
    end

    # Convert controller name into class
    # :users into UsersController
    def controller_class(controller_name)
      "#{controller_name.capitalize}Controller".constantize
    end

    def resources(controller_name, option = {only: [:index, :show, :new, :create, :edit, :update, :destroy]})
      controller_class = controller_class(controller_name)
      patterns = {
        index:    "^/#{controller_name}$",
        show:     "^/#{controller_name}/(?<id>\\d+)$",
        new:      "^/#{controller_name}/(?<id>\\d+)/new$",
        create:   "^/#{controller_name}$",
        edit:     "^/#{controller_name}/(?<id>\\d+)/edit$",
        update:   "^/#{controller_name}/(?<id>\\d+)$",
        destroy:  "^/#{controller_name}/(?<id>\\d+)$"
      }
      option[:only].each do |action|
        self.send METHODS[action], Regexp.new(patterns[action]), controller_class, action
      end
      # # index
      # get Regexp.new("^/#{controller_name}$"), controller_class, :index
      # # show
      # get Regexp.new("^/#{controller_name}/(?<id>\\d+)$"), controller_class, :show
      # # new
      # get Regexp.new("^/#{controller_name}/(?<id>\\d+)/new$"), controller_class, :new
      # # create
      # post Regexp.new("^/#{controller_name}$"), controller_class, :create
      # # edit
      # get Regexp.new("^/#{controller_name}/(?<id>\\d+)/edit$"), controller_class, :edit
      # # update
      # patch Regexp.new("^/#{controller_name}/(?<id>\\d+)$"), controller_class, :update
      # # destroy
      # delete Regexp.new("^/#{controller_name}/(?<id>\\d+)$"), controller_class, :destroy
    end

    # make each of these methods that
    # when called add route
    [:get, :post, :put, :delete, :patch].each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name|
        add_route(pattern, http_method, controller_class, action_name)
      end
    end

    # should return the route that matches this request
    def match(req)
      @routes.select do |route|
        route if route.matches?(req)
      end
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      if match(req).empty?
        res.status = 404
        res.body = File.read("public/404.html")
      else
        match(req).first.run(req, res)
      end
    end
  end
end
