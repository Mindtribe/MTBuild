module Rake

  require 'rake'

  # This is a top-level Rake task for creating a test application
  class TestApplicationTask < Task

    def initialize(task_name, app)
      super
    end

  end

  module DSL

    # DSL method to create a test application task.
    def test_application_task(*args, &block)
      new_task = Rake::TestApplicationTask.define_task(*args, &block)
    end

  end

end
