if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)
  
  load_dependency 'merb-slices'
  Merb::Plugins.add_rakefiles "fiveruns_tuneup_merb/merbtasks", "fiveruns_tuneup_merb/slicetasks", "fiveruns_tuneup_merb/spectasks"
  
  require 'fiveruns_tuneup_core'
  require File.dirname(__FILE__) / 'fiveruns_tuneup_merb' / 'instrumentation'
  require File.dirname(__FILE__) / 'fiveruns_tuneup_merb' / 'api_key'
  require File.dirname(__FILE__) / 'fiveruns_tuneup_merb' / 'runs'

  # Register the Slice for the current host application
  Merb::Slices.register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :fiveruns_tuneup_merb
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices.config[:fiveruns_tuneup_merb][:layout] ||= nil
  Merb::Slices.config[:fiveruns_tuneup_merb][:run_directory] ||= begin
    Merb.root / :tmp / :fiveruns_tuneup_merb / :runs
  end
  
  Fiveruns::Tuneup::STRIP_ROOT = Merb.root
  
  # All Slice code is expected to be namespaced inside a module
  module FiverunsTuneupMerb
    extend APIKey
    extend Runs
    
    # Slice metadata
    self.description = "Provides a FiveRuns TuneUp panel (http://tuneup.fiveruns.com)"
    self.version = "0.0.1"
    self.author = "FiveRuns Development Team <dev@fiveruns.com>"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
      Fiveruns::Tuneup::Run.directory = config[:run_directory]
      Fiveruns::Tuneup::Run.api_key  =  config[:api_key]
      Fiveruns::Tuneup.javascripts_path = FiverunsTuneupMerb.public_dir_for('javascripts')
      Fiveruns::Tuneup.stylesheets_path = FiverunsTuneupMerb.public_dir_for('stylesheets')
    end
        
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
      if Merb::Config[:adapter] != 'irb'
        Merb.logger.info "Instrumenting with TuneUp"
        ::Merb::Request.extend(FiverunsTuneupMerb::Instrumentation::Merb::Request)
        ::Merb::Controller.extend(FiverunsTuneupMerb::Instrumentation::Merb::Controller)
        if defined?(::DataMapper)
          ::DataMapper::Repository.extend(FiverunsTuneupMerb::Instrumentation::DataMapper::Repository)
        end
        log_share_status
      else
        Merb.logger.info "Not instrumenting with TuneUp (adapter is '#{Merb::Config[:adapter]}')"
      end
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(FiverunsTuneupMerb)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :fiveruns_tuneup_merb_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      # example of a named route
      # scope.match('/on.js').to(:controller => 'state', :action => 'on').name(:fiveruns_tuneup_merb_on)
    end
    
  end
  
  # Setup the slice layout for FiverunsTuneupMerb
  #
  # Use FiverunsTuneupMerb.push_path and FiverunsTuneupMerb.push_app_path
  # to set paths to fiveruns_tuneup_merb-level and app-level paths. Example:
  #
  # FiverunsTuneupMerb.push_path(:application, FiverunsTuneupMerb.root)
  # FiverunsTuneupMerb.push_app_path(:application, Merb.root / 'slices' / 'fiveruns_tuneup_merb')
  # ...
  #
  # Any component path that hasn't been set will default to FiverunsTuneupMerb.root
  
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  FiverunsTuneupMerb.setup_default_structure!
  
  # Add dependencies for other FiverunsTuneupMerb classes below. Example:
  # dependency "fiveruns_tuneup_merb/other"
  
end