module Rake

  require 'rake'

  class ApplicationTask < Task

    def initialize(task_name, app)
      super
    end

  end

  module DSL
    def application_task(*args, &block)
      new_task = Rake::ApplicationTask.define_task(*args, &block)
    end
  end

end
