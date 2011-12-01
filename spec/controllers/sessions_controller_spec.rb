require "spec_helper"

describe SessionsController do
  before do
    @api = mock_model("Configuration", :name => "api_secret", :value => "SOME_RANDOM_VALUE")
    OmniAuth.config.test_mode = true

  end
  describe "POST #create" do
    pending
  end


  describe "POST #create_meurio" do
    before do
      request.env["omniauth.auth"] = OmniAuth.config.add_mock(:meu_rio, {:uid => '123456'})
      auth = request.env["omniauth.auth"]

      Configuration.should_receive(:find_by_name).with(@api.name).and_return(@api)
      User.should_receive(:find_with_omni_auth).with(auth[:provider], auth[:uid].to_s)
    end
    context "when API secret and UID are present" do
      before do
       post :create_meurio, :api_secret => "SOME_RANDOM_VALUE", :meurio_uid => "SOME_ID"
      end
      its(:status) { should == 302 }
    end
    context "when API secret and UID aren't present" do
      before do
        post :create_meurio
      end
      its(:status) { should == 406 }
      it { should_not redirect_to root_path }
    end
  end
end
