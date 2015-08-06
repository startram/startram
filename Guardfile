if RUBY_PLATFORM.include?("darwin")
  require "rb-fsevent"
end

require "terminal-notifier-guard"

directories %w(spec src)

module ::Guard
  class CrystalApp < Plugin

    def initialize(options = {})
      super

      app_dir = File.dirname(__FILE__)
      app_name = app_dir.split("/").last
      default_app_file = "#{app_dir}/src/#{app_name}.cr"

      @app_file = default_app_file
    end

    def start
      compile
    end

    def stop
      kill_app
    end

    def reload
    end

    def run_all
    end

    def run_on_additions(paths)
      compile_and_restart
    end

    def run_on_modifications(paths)
      compile_and_restart
    end

    def run_on_removals(paths)
      compile_and_restart
    end

    private

    def compile
      time = Time.now
      command = "crystal build #{@app_file} -o #{output_file}"
      if system(command)
        elapsed = Time.now - time
        puts "Compiled in #{elapsed.round(2)}sec"
        #TerminalNotifier::Guard.success("Compiled")
        true
      else
        TerminalNotifier::Guard.failed("Compilation failed!")
        false
      end
    end

    def output_file
      "#{Dir.tmpdir}/#{@app_name}"
    end

    def run_app
      i, o, e, thread = Open3.open3(output_file)
      @app_pid = thread[:pid]
      puts "Running app on #{@app_pid}"
    end

    def kill_app
      if @app_pid
        puts "Killing #{@app_pid}"
        Process.kill("QUIT", @app_pid)
      end
    end

    def compile_and_restart
      kill_app
      if compile
        run_app
      end
    end
  end

  class CrystalSpec < Plugin
    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      super
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
      run_all_specs
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
      run_all_specs
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
      run_all_specs
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
      run_all_specs
    end

    private

    def run_all_specs
      if system("crystal spec")
        TerminalNotifier::Guard.success("Specs passed :)")
      else
        TerminalNotifier::Guard.failed("Specs failed :(")
      end
    end
  end
end

#guard "crystal_app"

guard "crystal_spec" do
  watch %r(./**/*.cr)
end
