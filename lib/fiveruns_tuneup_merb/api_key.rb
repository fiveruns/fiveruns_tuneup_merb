require 'yaml'

module FiverunsTuneupMerb
    
  module APIKey
    
    def log_share_status
      if Fiveruns::Tuneup::Run.api_key?
        Merb.logger.debug "TuneUp is configured for sharing."
      else
        Merb.logger.warn "TuneUp is NOT configured for sharing."
        Merb.logger.warn "You must set Merb::Slices.config[:fiveruns_tuneup_merb][:api_key] to share runs."
      end
    end
    
  end
  
end
    