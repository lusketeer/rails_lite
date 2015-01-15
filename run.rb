require_relative "collection"

# ActiveRecordLite::DBConnection.reset

router = ActionDispatchLite::Router.new
router.draw do
  resources :heros, only: [:index]
  resources :cats
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
