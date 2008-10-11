class FiverunsTuneupMerb::Runs < FiverunsTuneupMerb::Application
  
  provides :json
  
  def share
    run_id = Fiveruns::Tuneup::Run.share(params[:slug])
    result = if run_id
      {:run_id => run_id}
    else
      {:error => "Could not send run.  Please contact support@fiveruns.com if this problem persists."}
    end
    render_json result.to_json
  end
  
end