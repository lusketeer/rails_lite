require 'byebug'
require 'sqlite3'

# underscore and constantize methods
require 'active_support/inflector'

# Action Controller
require_relative "lib/action_controller_lite/base"
require_relative "lib/action_controller_lite/param"
require_relative "lib/action_controller_lite/session"

# Action Dispatch
require_relative "lib/action_dispatch_lite/router"

# Active Record
require_relative "lib/active_record_lite/db_connection"
require_relative "lib/active_record_lite/associatable"
require_relative "lib/active_record_lite/searchable"
require_relative "lib/active_record_lite/base"

Dir[File.dirname(__FILE__) + "/lib/active_record_lite/**/*.rb"].each do |file|
  require file
end

Dir[File.dirname(__FILE__) + "/app/**/*.rb"].each do |file|
  require file
end
