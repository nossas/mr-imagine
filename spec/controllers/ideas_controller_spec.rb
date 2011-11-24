require 'spec_helper'

describe IdeasController do
  subject{ response }
  describe 'GET index' do
    before do
      Idea.stub_chain(:featured, :primary, :limit, :all).and_return('featured_ideas')
      Idea.stub_chain(:popular, :limit, :all).and_return("popular_ideas")
      Idea.stub_chain(:not_featured, :recent, :limit, :all).and_return("recent_ideas")
      Idea.stub(:count).and_return("ideas_count")
    end
    context "when iframe is true" do
      before do
        get :index, :locale => :pt, :iframe => true
      end
      its(:status){ should == 200 }
      it{ should render_template 'layouts/iframe' }
      it{ assigns(:featured).should == "featured_ideas" }
      it{ assigns(:popular).should == "popular_ideas" }
      it{ assigns(:recent).should == "recent_ideas" }
      it{ assigns(:count).should == "ideas_count" }
      it{ session[:iframe].should be_true}
    end

    context "when iframe is nil" do
      before do
        get :index, :locale => :pt
      end
      its(:status){ should == 200 }
      it{ should render_template 'layouts/application' }
      it{ assigns(:featured).should == "featured_ideas" }
      it{ assigns(:popular).should == "popular_ideas" }
      it{ assigns(:recent).should == "recent_ideas" }
      it{ assigns(:count).should == "ideas_count" }
      it{ session[:iframe].should be_nil }
    end
  end

  describe 'GET show' do
    before do
      @idea = Factory.create(:idea)
    end
    context "when iframe is true" do
      before do
        session[:iframe] = true
        get :show, :id => @idea.id, :locale => :pt
      end
      its(:status){ should == 200 }
      it{ should render_template "layouts/iframe"}
    end
    context "when iframe is nil" do
      before do
        session[:iframe] = nil
        get :show, :id => @idea.id, :locale => :pt
      end
      it{ should render_template "layouts/application"}
      its(:status){ should == 200 }
    end
  end
end
