module HelperMethods
  # Put helper methods you need to be available in all tests here.
  def fake_login(params = '')
    visit fake_login_path + '?' + params
  end
  def current_user
    User.find_by_uid 'fake_login'
  end
  def click_login
    visit homepage
    find("#login .overlay").visible?.should be_false
    find("#login .popup").visible?.should be_false
    page.should have_no_css('#user')
    click_link 'Fazer login'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
