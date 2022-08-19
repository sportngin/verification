require 'bundler/setup'
require 'test/unit'
require 'mocha/setup'
require 'active_support'
require 'action_controller'
require 'byebug'

if ActiveSupport::VERSION::MAJOR > 3
  require 'active_support/testing/autorun'
end

require File.dirname(__FILE__) + '/../lib/action_controller/verification'

SharedTestRoutes = ActionDispatch::Routing::RouteSet.new
SharedTestRoutes.draw do
  match ":controller(/:action(/:id))", :via => :all
end

ActionController::Base.send :include, SharedTestRoutes.url_helpers

module ActionController
  class TestCase
    setup { @routes = SharedTestRoutes }
  end
end

if RUBY_VERSION >= '2.6.0'
  if ActiveSupport::VERSION::MAJOR < 5
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  end
end
