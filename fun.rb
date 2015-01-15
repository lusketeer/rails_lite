require_relative "collection"

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

class StatusesController < ActionControllerLite::Base
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params[:cat_id])
    end

    render_content(statuses.to_s, "text/text")
  end
end

class CatsController < ActionControllerLite::Base
  def index
    render_content($cats.to_s, "text/text")
  end
end

router = ActionDispatchLite::Router.new
router.draw do
  resources :cats
  # get Regexp.new("^/cats$"), Cats2Controller, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start