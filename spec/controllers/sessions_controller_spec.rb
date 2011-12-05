require "spec_helper"

describe SessionsController do
  subject{ response }
  before do
    @api = mock_model("Configuration", :name => "api_secret", :value => "SOME_RANDOM_VALUE")
    OmniAuth.config.test_mode = true

  end
  describe "POST #create" do
    pending
  end


  describe "POST #create_meurio" do
    before do
      Configuration.should_receive(:find_by_name).with(@api.name).and_return(@api)
    end

    context "when API secret and UID are present but the user is new" do
      before do
        User.should_receive(:find_with_omni_auth).with('meu_rio', 'SOME_ID').and_return(nil)
        User.should_receive(:create!).with(:provider => 'meu_rio', :uid => 'SOME_ID', :name => 'test name').and_return(stub_model(User, :id => 666))
        request.session_options[:id] = '123'
        post :create_meurio, :api_secret => "SOME_RANDOM_VALUE", :uid => "SOME_ID", :name => 'test name'
      end
      its(:status) { should == 302 }
      its(:body) { should == {:sid => '123'}.to_json }
      it{ session[:user_id].should == 666 }
    end

    context "when API secret and UID aren't present" do
      before do
        post :create_meurio
      end
      its(:status) { should == 406 }
      it { should_not redirect_to root_path }
    end

    context "when just API secret is present" do
      before do
        post :create_meurio, :api_secret => "SOME_RANDOM_VALUE"
      end
      its(:status) { should == 406 }
      it { should_not redirect_to root_path }
    end

    context "when just UID is present" do
      before do
        post :create_meurio, :uid => "SOME_RANDOM_VALUE"
      end
      its(:status) { should == 406 }
      it { should_not redirect_to root_path }
    end
  end
end
