require "sqlite3"
require "date"

module SimpleBench
  # take benchmark ips values and store in a sqlite database
  # keys are based upon sha
  # time (of the commit) is stored to provide data suitable
  # for a time series database
  class DatabaseReport
    include Enumerable

    # this is for tests - get out of here
    attr_reader :dbfilename
    # default sha for inserts
    attr_accessor :sha
    # date of current metrics
    attr_accessor :now

    def initialize(dbfilename, sha, now)
      @dbfilename = dbfilename
      @sha = sha
      @now = now
    end

    # @param [Array<Report::Entry>] entries report entries
    def store(entries)
      entries.each do |entry|
        add_metrics(
          entry.label,
          entry.microseconds,
          entry.iterations,
          entry.ips,
          entry.ips_sd,
          entry.measurement_cycle
        )
      end
    end

    # Add metrics to the database
    # equivalent to Benchmark::IPS::Report::Entry.
    # @param [#to_s] label Label of entry.
    # @param [Integer] us Measured time in microsecond.
    # @param [Integer] iters Iterations.
    # @param [Float] ips Iterations per second.
    # @param [Float] ips_sd Standard deviation of iterations per second.
    # @param [Integer] cycles Number of Cycles.
    def add_metrics(label, us, iters, ips, ips_sd, cycles)
      insert.execute sha, now, label, us, iters, ips, ips_sd, cycles
    end

    # def [](key)
    #   db.execute("select ips, stddev from metrics where sha = ? and name = ?", sha, key).map { |row| row.first }.first
    # end

    # def include?(key)
    #   !!self[key]
    # end

    def results_as_hash=(value)
      db.results_as_hash = value
    end

    def each(&block)
      # order by rowid
      db.execute "select * from metrics order by created_at, label", &block
    end

    def others(&block)
      db.execute "select * from metrics where sha != ? order by created_at, label", sha, &block
    end

    def delete_metrics
      db.execute "delete from metrics where sha = ?", sha
    end

    def has_metrics?
      db.execute "select 1 from metrics where sha = ?", sha do |row|
        return true
      end
      return false
    end

    private

    def db
      @db ||= create
    end

    def insert
      @insert ||= db.prepare "insert into metrics (sha, created_at, label, microseconds, iterations, ips, ips_sd, cycles) values (?, ?, ?, ?, ?, ?, ?, ?)"
    end

    def create
      SQLite3::Database.new(dbfilename).tap do |db|
        db.execute("create table if not exists metrics ( " +
          "sha text, created_at datetime, label text, microseconds integer, iterations integer, "+
          "ips float, ips_sd float, cycles integer)")
      end
    end
  end
end
