module Rake

  require 'rake'

  # This is a top-level Rake task for creating an application
  class ApplicationTask < Task

    def initialize(task_name, app)
      super
    end

  end

  module DSL

    # DSL method to create an application task.
    def application_task(*args, &block)
      new_task = Rake::ApplicationTask.define_task(*args, &block)
    end

  end

end
