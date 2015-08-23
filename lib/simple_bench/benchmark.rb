module SimpleBench
  class Benchmark
    attr_accessor :dir
    attr_accessor :prune
    attr_accessor :dbfilename
    # @param [String] dir directory with source files (for git operations)
    # @param [String] dbfilename full path to db filename
    def initialize(dir, dbfilename)
      @dbfilename = dbfilename
      @dir = dir
      @prune = true
    end

    # @param [Array<Benchmark::Report::Entry>] entries benchmark ips report entries
    def run(entries)
      puts "running #{db.sha}"
      if db.has_metrics?
        puts "exists" 
        if prune
          puts "deleting #{db.sha}"
          db.delete_metrics # delete current metrics
        end
      end
      db.store(entries)
    end

    def grouped_results
      db.results_as_hash = true
      results = db.each.map do |row|
        {
          sha: row["sha"],
          date: row["created_at"],
          label: row["label"],
          ips: row["ips"].round,
          ips_sd: row["ips_sd"].round
        }
      end
      multi_group(results, [:sha, :label])
    end

    # TODO: respect fields parameter
    def multi_group(results, fields)

      g = results.group_by { |r| r[:sha] }
      # group second layer by label
      g.each { |h, hh| g[h] = hh.group_by { |hhh| hhh[:label] } }
      g
    end

    # results for line charts
    def show
      results = grouped_results
      metric_names = results[results.keys.first].keys.map { |m| m.gsub(/(init_|run_)/,'') }.uniq
      # would like to sort metric_names by ips (just for one)

      puts "var data = [{"
      results.each_with_index do |(sha, metrics), i|
        puts "  ]}, {" if i > 0
        date = metrics.first[1].first[:date] #.split("T").first
        puts "  name: \"#{sha}\", date: \"#{date}\", values: ["

        metric_names.each_with_index do |bench, j|
          metric = metrics[bench] || metrics["run_#{bench}"]
          metric = metric.first

          init_metric = metrics["init_#{bench}"]
          init_metric = init_metric.first if init_metric
          puts "," if j > 0
          print "    {bench: %-20s, ips: %-8s, sd: %-8s" %
          ["\"#{bench}\"",metric[:ips], metric[:ips_sd]]
          if init_metric
            print ", init_ips: %-8s, init_sd: %-8s" %
            [init_metric[:ips], init_metric[:ips_sd]]
          end
          print "}"
        end
        puts
      end
      puts "]}];"
    end

    def has_metrics?
      db.has_metrics?
    end

    def modified?
      git.modified?
    end

    private

    def git
      @git ||= GitInfo.new(dir)
    end

    def db
      @db ||=
        begin
          dbname = File.join(dbfilename)
          DatabaseReport.new(dbname, git.sha, git.now)
        end
    end
  end
end
