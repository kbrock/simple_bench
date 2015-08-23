
module SimpleBench
  class Cli
    def parse(argv, env = [])
      self
    end

    def run
      run_web
      self
    end

    def run_web
      require 'simple_bench/app'
      SimpleBench::App.run!
    end
  end
end

