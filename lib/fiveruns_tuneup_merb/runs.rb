module FiverunsTuneupMerb
    
  module Runs
    
    def create_run_for(url, data)
      run = Fiveruns::Tuneup::Run.new(url, data)
      run.save
    end

  end
  
end