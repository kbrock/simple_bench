#!/usr/bin/env ruby

require 'temple'
$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'simple_bench'
# benchmark test file

DB_FILENAME=File.expand_path("../temple.db", __FILE__)

class TempleBench
TEMPLATES = {
:one => %q{
%% hi
= hello
<% 3.times do |n| %>
* <%= n %>
<% end %>
},
:comments => %q{
hello
  <%# comment -- ignored -- useful in testing %>
world},
:perper => %q{
<%%
<% if true %>
  %%>
<% end %>
},
:escape => '<%= "<" %>',
:noescape => '<%== "<" %>',
:nontrim  => %q{
%% hi
= hello
<% 3.times do |n| %>
* <%= n %>
<% end %>
}
}
  class Context
    def header
      'Colors'
    end

    def item
      [ { name: 'red',   current: true,  url: '#red'   },
        { name: 'green', current: false, url: '#green' },
        { name: 'blue',  current: false, url: '#blue'  } ]
    end
  end

  attr_accessor :dir

  def initialize(dir)
    @dir = dir
  end

  def run(flags = {})
    bench = SimpleBench::Benchmark.new(dir, DB_FILENAME)
    if bench.modified? || !bench.has_metrics? || flags[:force]
      bench.run(report_entries)
    end
    bench.show
  end

  # @return [Benchmark::Report] benchmark ips report
  def report_entries
    ctx = Context.new
    Benchmark.ips(1,1) do |x|
      #save_bench(:key => )
      TEMPLATES.each do |name, code|
        x.report("init_#{name}") do |count|
          i = count
          while i > 0
            Temple::ERB::Template.new { code }
            i -= 1
          end
        end
    #   end
    # end
    # Benchmark.ips(1,1) do |x|
    #   TEMPLATES.each do |name, code|
        x.report("run_#{name}") do |count|
          tmpl = Temple::ERB::Template.new { code }
          i = count
          while i > 0
            tmpl.render(ctx)
            i -= 1
          end
        end
      end
    end.entries
  end
end


TEMPLE_DIR=File.expand_path("../../temple", __FILE__)
$:.unshift("#{TEMPLE_DIR}/lib")

flags = {}
flags[:force] = ARGV.include?("-f")
TempleBench.new(TEMPLE_DIR).run(flags)
