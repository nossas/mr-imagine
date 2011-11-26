require 'spec_helper'

describe IdeasController do
  subject{ response }
  before do
    @idea_owner ||= Factory.create(:user)
    @current_user ||= Factory.create(:user)

    @idea = mock_model(Idea, :id => 1, :user_id => @idea_owner.id)
    @fork = mock_model(Idea, :id => 2, :user_id => @current_user.id)
  end

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
    after do
      @idea.destroy
    end
  end

  describe "POST create_fork_idea" do

    before do  
      Idea.stub!(:find, @idea.id).and_return(@idea)
      @idea.stub!(:create_fork, @current_user).and_return(@fork)
    end

    context "when iframe is true and user IS logged in" do   

      before do 
        session[:iframe] = true
        session[:user_id] = @current_user.id
        post :create_fork, :locale => :pt, :id => @idea.id
      end

      its(:status){ should == 302 }
      it { should redirect_to idea_path(@fork) }
    end

    context "when iframe is nil and user IS logged in" do

      before do
        session[:iframe] = nil
        session[:user_id] = @current_user.id
        post :create_fork, :locale => :pt, :id => @idea.id
      end

      its(:status) { should == 302 }
      it { should redirect_to idea_path(@fork) }
    end

    context "when iframe is true and user IS NOT logged" do

      before do
        session[:iframe] = true
        session[:user_id] = nil
        post :create_fork, :locale => :pt, :id => @idea.id
      end

      # Check later for rescue_from CanCan:AccessDenied in ApplicationController
      its(:status) { should == 401 } 
      it { should_not redirect_to idea_path(@fork)}
    end
  end


  describe "PUT merge_idea" do

    before do
      Idea.should_receive(:find).twice.with(@idea.id).and_return(@idea)
      @idea.stub!(:merge!, @fork.id).and_return(@idea)
    end

    context "when iframe is true and user IS logged in" do
      before do
        session[:iframe] = true
        session[:user_id] = @current_user.id
        put :merge, :locale => :pt, :id => @idea.id, :from_id => @fork.id
      end

      its(:status) { should == 302 }
      it { should redirect_to idea_path(@idea) }
    end

    context "when iframe is nil and user IS logged in" do
      before do
        session[:iframe] = nil
        session[:user_id] = @current_user.id
        put :merge, :locale => :pt, :id => @idea.id, :from_id => @fork.id
      end
      its(:status) { should == 302 }
      it { should redirect_to idea_path(@idea) }

    end
  end

  after do
    @idea_owner.destroy
    @current_user.destroy
  end
end