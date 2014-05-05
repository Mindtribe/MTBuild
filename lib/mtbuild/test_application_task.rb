module Rake

  require 'rake'

  class TestApplicationTask < Task

    def initialize(task_name, app)
      super
    end

  end

  module DSL
    def test_application_task(*args, &block)
      new_task = Rake::TestApplicationTask.define_task(*args, &block)
    end
  end

end
