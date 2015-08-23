require "simple_bench/version"

BENCHMARK_DIR=File.expand_path(File.dirname(__FILE__))
$:.unshift(BENCHMARK_DIR)

require 'benchmark/ips'
require 'simple_bench/database_report'
require 'simple_bench/git_info'
require 'simple_bench/benchmark'

module SimpleBench
  # Your code goes here...
end
