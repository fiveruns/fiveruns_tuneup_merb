require File.dirname(__FILE__) + '/../spec_helper'

describe "FiverunsTuneupMerb::Main (controller)" do
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { |r| r.add_slice(:FiverunsTuneupMerb) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should have access to the slice module" do
    controller = dispatch_to(FiverunsTuneupMerb::Main, :index)
    controller.slice.should == FiverunsTuneupMerb
    controller.slice.should == FiverunsTuneupMerb::Main.slice
  end
  
  it "should have an index action" do
    controller = dispatch_to(FiverunsTuneupMerb::Main, :index)
    controller.status.should == 200
    controller.body.should contain('FiverunsTuneupMerb')
  end
  
  it "should work with the default route" do
    controller = get("/fiveruns_tuneup_merb/main/index")
    controller.should be_kind_of(FiverunsTuneupMerb::Main)
    controller.action_name.should == 'index'
  end
  
  it "should work with the example named route" do
    controller = get("/fiveruns_tuneup_merb/index.html")
    controller.should be_kind_of(FiverunsTuneupMerb::Main)
    controller.action_name.should == 'index'
  end
  
  it "should have routes in FiverunsTuneupMerb.routes" do
    FiverunsTuneupMerb.routes.should_not be_empty
  end
  
  it "should have a slice_url helper method for slice-specific routes" do
    controller = dispatch_to(FiverunsTuneupMerb::Main, 'index')
    controller.slice_url(:action => 'show', :format => 'html').should == "/fiveruns_tuneup_merb/main/show.html"
    controller.slice_url(:fiveruns_tuneup_merb_index, :format => 'html').should == "/fiveruns_tuneup_merb/index.html"
  end
  
  it "should have helper methods for dealing with public paths" do
    controller = dispatch_to(FiverunsTuneupMerb::Main, :index)
    controller.public_path_for(:image).should == "/slices/fiveruns_tuneup_merb/images"
    controller.public_path_for(:javascript).should == "/slices/fiveruns_tuneup_merb/javascripts"
    controller.public_path_for(:stylesheet).should == "/slices/fiveruns_tuneup_merb/stylesheets"
  end
  
  it "should have a slice-specific _template_root" do
    FiverunsTuneupMerb::Main._template_root.should == FiverunsTuneupMerb.dir_for(:view)
    FiverunsTuneupMerb::Main._template_root.should == FiverunsTuneupMerb::Application._template_root
  end

end