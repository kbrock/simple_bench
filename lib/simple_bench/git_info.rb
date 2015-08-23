module SimpleBench
  class GitInfo
    attr_accessor :dir
    attr_accessor :sha_length

    def initialize(dir)
      @dir = dir
      @sha_length = 8
    end

    # length to trim the sha (default: 8)
    attr_accessor :sha_length

    def branch
      @branch ||= modified? ? 'current' : calc_branch
    end

    # git
    def sha
      @sha ||= modified? ? 'current' : calc_sha[0...@sha_length]
    end

    def now
      @now ||= modified? ? DateTime.now.to_s : calc_date
    end

    # use unstaged? or changed? based upon your needs
    def modified?
      refresh_index || changed? || unstaged?
    end

    def calc_branch
      `cd #{dir} ; git symbolic-ref -q --short HEAD`.chomp
    end

    def calc_sha
      `cd #{dir} ; git show-ref --head --hash HEAD`.chomp
    end

    def calc_date
      `cd #{dir} ; git log -1 --format=%cd --date=iso-strict`.chomp
    end

    # @return [Boolean] false saying nothing has changed
    def refresh_index
      `cd #{dir} ; git update-index -q --ignore-submodules --refresh`
      false
    end

    # @return [Boolean] true if unstaged files exist
    def unstaged?
      `cd #{dir} ; git diff-files --quiet --ignore-submodules --`
      !$?.success?
    end

    # @return [Boolean] true if files are changed
    def changed?
      `cd #{dir} ; git diff-index --cached --quiet HEAD --ignore-submodules --`
      !$?.success?
    end
  end
end
