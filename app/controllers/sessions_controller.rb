class SessionsController < ApplicationController

  skip_before_filter :detect_locale
  skip_before_filter :verify_authenticity_token, :only => [:create_meurio]

  def auth
    session[:return_to] = params[:return_to]
    session[:remember_me] = params[:remember_me]
    redirect_to "/auth/#{params[:provider]}"
  end


  def create_meurio
    auth = request.env["omniauth.auth"]
    user = User.find_with_omni_auth(auth[:provider], auth[:uid].to_s)
    api_secret = Configuration.find_by_name("api_secret")
    new_user = false
    if not user
      user = User.create_with_omniauth(auth)
      new_user = true
    end

    if params[:api_secret] and params[:api_secret] == api_secret.value
      render :json => { :sid => request.session_options[:id] }, :status => :found
    else
     redirect_to :root, :status => :not_acceptable
    end
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_with_omni_auth(auth["provider"], auth["uid"].to_s)
    new_user = false
    unless user
      user = User.create_with_omniauth(auth)
      new_user = true
    end
    session[:return_to] = user_path(user) if session[:return_to].nil? or session[:return_to].empty? if new_user
    session[:user_id] = user.id
    if session[:remember_me]
      cookies[:remember_me_id] = { :value => user.id, :expires => 30.days.from_now }
      cookies[:remember_me_hash] = { :value => user.remember_me_hash, :expires => 30.days.from_now }
    end
    flash[:success] = t('sessions.post_auth.success', :name => user.display_name)
    redirect_back_or_default :root
  end

  def destroy
    session[:user_id] = nil
    cookies.delete :remember_me_id if cookies[:remember_me_id]
    cookies.delete :remember_me_hash if cookies[:remember_me_hash]
    flash[:success] = t('sessions.destroy.success')
    redirect_to :root
  end

  def failure
    flash[:failure] = t('sessions.failure.error')
    redirect_to :root
  end

  def fake_create
    return render :status => :forbidden unless Rails.env.test?
    user = Factory(:user, :uid => 'fake_login')
    user.admin = true if params[:root_admin] == 'true'
    user.save
    session[:user_id] = user.id
    flash[:success] = t('sessions.post_auth.success', :name => user.display_name)
    redirect_to :root
  end

end
