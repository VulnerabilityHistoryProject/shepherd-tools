require 'os'
require 'parallel'

# Intended to be included so you can do parallelism on non-Windows
# but still run on Windows
module VHP
  module Parallelism

    def parallel_maybe(iterable, in_processes: 8, progress: prog_string)
      if OS.windows?
        warn "WARNING: OS is Windows, so this won't run in parallel. Run in Linux for better performance."
        iterable.each { |i| yield(i) }
      else
        Parallel.each(iterable, in_processes: 8, progress: 'Progress') do |i|
          yield(i)
        end
      end
    end

  end
end
