namespace :slices do
  namespace :fiveruns_tuneup_merb do
  
    desc "Install FiverunsTuneupMerb"
    task :install => [:preflight, :setup_directories, :copy_assets, :migrate]
    
    desc "Test for any dependencies"
    task :preflight do # see slicetasks.rb
    end
  
    desc "Setup directories"
    task :setup_directories do
      puts "Creating directories for host application"
      FiverunsTuneupMerb.mirrored_components.each do |type|
        if File.directory?(FiverunsTuneupMerb.dir_for(type))
          if !File.directory?(dst_path = FiverunsTuneupMerb.app_dir_for(type))
            relative_path = dst_path.relative_path_from(Merb.root)
            puts "- creating directory :#{type} #{File.basename(Merb.root) / relative_path}"
            mkdir_p(dst_path)
          end
        end
      end
    end
    
    desc "Copy stub files to host application"
    task :stubs do
      puts "Copying stubs for FiverunsTuneupMerb - resolves any collisions"
      copied, preserved = FiverunsTuneupMerb.mirror_stubs!
      puts "- no files to copy" if copied.empty? && preserved.empty?
      copied.each { |f| puts "- copied #{f}" }
      preserved.each { |f| puts "! preserved override as #{f}" }
    end
    
    desc "Copy stub files and views to host application"
    task :patch => [ "stubs", "freeze:views" ]
  
    desc "Copy public assets to host application"
    task :copy_assets do
      puts "Copying assets for FiverunsTuneupMerb - resolves any collisions"
      copied, preserved = FiverunsTuneupMerb.mirror_public!
      puts "- no files to copy" if copied.empty? && preserved.empty?
      copied.each { |f| puts "- copied #{f}" }
      preserved.each { |f| puts "! preserved override as #{f}" }
    end
    
    desc "Migrate the database"
    task :migrate do # see slicetasks.rb
    end
    
    desc "Freeze FiverunsTuneupMerb into your app (only fiveruns_tuneup_merb/app)" 
    task :freeze => [ "freeze:app" ]

    namespace :freeze do
      
      desc "Freezes FiverunsTuneupMerb by installing the gem into application/gems using merb-freezer"
      task :gem do
        begin
          Object.const_get(:Freezer).freeze(ENV["GEM"] || "fiveruns_tuneup_merb", ENV["UPDATE"], ENV["MODE"] || 'rubygems')
        rescue NameError
          puts "! dependency 'merb-freezer' missing"
        end
      end
      
      desc "Freezes FiverunsTuneupMerb by copying all files from fiveruns_tuneup_merb/app to your application"
      task :app do
        puts "Copying all fiveruns_tuneup_merb/app files to your application - resolves any collisions"
        copied, preserved = FiverunsTuneupMerb.mirror_app!
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freeze all views into your application for easy modification" 
      task :views do
        puts "Copying all view templates to your application - resolves any collisions"
        copied, preserved = FiverunsTuneupMerb.mirror_files_for :view
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freeze all models into your application for easy modification" 
      task :models do
        puts "Copying all models to your application - resolves any collisions"
        copied, preserved = FiverunsTuneupMerb.mirror_files_for :model
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freezes FiverunsTuneupMerb as a gem and copies over fiveruns_tuneup_merb/app"
      task :app_with_gem => [:gem, :app]
      
      desc "Freezes FiverunsTuneupMerb by unpacking all files into your application"
      task :unpack do
        puts "Unpacking FiverunsTuneupMerb files to your application - resolves any collisions"
        copied, preserved = FiverunsTuneupMerb.unpack_slice!
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
    end
    
  end
end