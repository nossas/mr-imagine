require "spec_helper"

describe ApplicationController do
  describe "#create_session_from_params" do
    let(:session_data){ mock_model(ActiveRecord::Base, :data => {:user_id => 123}) }
    before do
      controller.params[:sid] = 1
      ActiveRecord::SessionStore::Session.should_receive(:find_by_session_id).with(1).and_return(session_data)
    end

    it do
      subject.send(:create_session_from_params)
      session[:user_id].should == 123
    end
  end
end
