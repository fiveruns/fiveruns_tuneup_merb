require File.dirname(__FILE__) + '/spec_helper'

describe "FiverunsTuneupMerb (module)" do
  
  it "should have proper specs"
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { |r| r.add_slice(:FiverunsTuneupMerb) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should be registered in Merb::Slices.slices" do
    Merb::Slices.slices.should include(FiverunsTuneupMerb)
  end
  
  it "should be registered in Merb::Slices.paths" do
    Merb::Slices.paths[FiverunsTuneupMerb.name].should == current_slice_root
  end
  
  it "should have an :identifier property" do
    FiverunsTuneupMerb.identifier.should == "fiveruns_tuneup_merb"
  end
  
  it "should have an :identifier_sym property" do
    FiverunsTuneupMerb.identifier_sym.should == :fiveruns_tuneup_merb
  end
  
  it "should have a :root property" do
    FiverunsTuneupMerb.root.should == Merb::Slices.paths[FiverunsTuneupMerb.name]
    FiverunsTuneupMerb.root_path('app').should == current_slice_root / 'app'
  end
  
  it "should have a :file property" do
    FiverunsTuneupMerb.file.should == current_slice_root / 'lib' / 'fiveruns_tuneup_merb.rb'
  end
  
  it "should have metadata properties" do
    FiverunsTuneupMerb.description.should == "FiverunsTuneupMerb is a chunky Merb slice!"
    FiverunsTuneupMerb.version.should == "0.0.1"
    FiverunsTuneupMerb.author.should == "YOUR NAME"
  end
  
  it "should have :routes and :named_routes properties" do
    FiverunsTuneupMerb.routes.should_not be_empty
    FiverunsTuneupMerb.named_routes[:fiveruns_tuneup_merb_index].should be_kind_of(Merb::Router::Route)
  end

  it "should have an url helper method for slice-specific routes" do
    FiverunsTuneupMerb.url(:controller => 'main', :action => 'show', :format => 'html').should == "/fiveruns_tuneup_merb/main/show.html"
    FiverunsTuneupMerb.url(:fiveruns_tuneup_merb_index, :format => 'html').should == "/fiveruns_tuneup_merb/index.html"
  end
  
  it "should have a config property (Hash)" do
    FiverunsTuneupMerb.config.should be_kind_of(Hash)
  end
  
  it "should have bracket accessors as shortcuts to the config" do
    FiverunsTuneupMerb[:foo] = 'bar'
    FiverunsTuneupMerb[:foo].should == 'bar'
    FiverunsTuneupMerb[:foo].should == FiverunsTuneupMerb.config[:foo]
  end
  
  it "should have a :layout config option set" do
    FiverunsTuneupMerb.config[:layout].should == :fiveruns_tuneup_merb
  end
  
  it "should have a dir_for method" do
    app_path = FiverunsTuneupMerb.dir_for(:application)
    app_path.should == current_slice_root / 'app'
    [:view, :model, :controller, :helper, :mailer, :part].each do |type|
      FiverunsTuneupMerb.dir_for(type).should == app_path / "#{type}s"
    end
    public_path = FiverunsTuneupMerb.dir_for(:public)
    public_path.should == current_slice_root / 'public'
    [:stylesheet, :javascript, :image].each do |type|
      FiverunsTuneupMerb.dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a app_dir_for method" do
    root_path = FiverunsTuneupMerb.app_dir_for(:root)
    root_path.should == Merb.root / 'slices' / 'fiveruns_tuneup_merb'
    app_path = FiverunsTuneupMerb.app_dir_for(:application)
    app_path.should == root_path / 'app'
    [:view, :model, :controller, :helper, :mailer, :part].each do |type|
      FiverunsTuneupMerb.app_dir_for(type).should == app_path / "#{type}s"
    end
    public_path = FiverunsTuneupMerb.app_dir_for(:public)
    public_path.should == Merb.dir_for(:public) / 'slices' / 'fiveruns_tuneup_merb'
    [:stylesheet, :javascript, :image].each do |type|
      FiverunsTuneupMerb.app_dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a public_dir_for method" do
    public_path = FiverunsTuneupMerb.public_dir_for(:public)
    public_path.should == '/slices' / 'fiveruns_tuneup_merb'
    [:stylesheet, :javascript, :image].each do |type|
      FiverunsTuneupMerb.public_dir_for(type).should == public_path / "#{type}s"
    end
  end
  
  it "should have a public_path_for method" do
    public_path = FiverunsTuneupMerb.public_dir_for(:public)
    FiverunsTuneupMerb.public_path_for("path", "to", "file").should == public_path / "path" / "to" / "file"
    [:stylesheet, :javascript, :image].each do |type|
      FiverunsTuneupMerb.public_path_for(type, "path", "to", "file").should == public_path / "#{type}s" / "path" / "to" / "file"
    end
  end
  
  it "should have a app_path_for method" do
    FiverunsTuneupMerb.app_path_for("path", "to", "file").should == FiverunsTuneupMerb.app_dir_for(:root) / "path" / "to" / "file"
    FiverunsTuneupMerb.app_path_for(:controller, "path", "to", "file").should == FiverunsTuneupMerb.app_dir_for(:controller) / "path" / "to" / "file"
  end
  
  it "should have a slice_path_for method" do
    FiverunsTuneupMerb.slice_path_for("path", "to", "file").should == FiverunsTuneupMerb.dir_for(:root) / "path" / "to" / "file"
    FiverunsTuneupMerb.slice_path_for(:controller, "path", "to", "file").should == FiverunsTuneupMerb.dir_for(:controller) / "path" / "to" / "file"
  end
  
  it "should keep a list of path component types to use when copying files" do
    (FiverunsTuneupMerb.mirrored_components & FiverunsTuneupMerb.slice_paths.keys).length.should == FiverunsTuneupMerb.mirrored_components.length
  end
  
end