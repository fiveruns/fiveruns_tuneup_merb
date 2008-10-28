namespace :slices do
  namespace :fiveruns_tuneup_merb do
  
    desc "Install FiveRuns TuneUp"
    task :install => :copy_assets
    
    desc "Copy assets for FiveRuns TuneUp"
    task :copy_assets do
      puts "Copying assets for FiverunsTuneupMerb - resolves any collisions"
      copied, preserved = FiverunsTuneupMerb.mirror_public!
      puts "- no files to copy" if copied.empty? && preserved.empty?
      copied.each { |f| puts "- copied #{f}" }
      preserved.each { |f| puts "! preserved override as #{f}" }
    end
    
  end
end