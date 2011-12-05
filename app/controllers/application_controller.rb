class ApplicationController < ActionController::Base

  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |e|
    render :json => { :status => :error }, :status => 401 if request.xhr?
    render :file => "public/401.html", :status => :unauthorized if not request.xhr?
  end

  helper_method :current_user, :replace_locale, :site_name, :facebook_admins, :analytics_account, :base_url
  before_filter :set_locale
  before_filter :detect_locale
  before_filter :create_session_from_params

  private
  
  def site_name
    @site_name ||= Configuration.find_by_name('site_name').value
  rescue
  end
  
  def facebook_admins
    @facebook_admins ||= Configuration.find_by_name('fb:admins').value
  rescue
  end
  
  def analytics_account
    @analytics_account ||= Configuration.find_by_name('analytics_account').value
  rescue
  end
  
  def base_url
    "#{request.protocol}#{request.host}#{":#{request.port}" if request.port}"
  end
  
  def set_locale
    return unless params[:locale]
    I18n.locale = params[:locale]
    return unless current_user
    current_user.update_attribute :locale, params[:locale] if params[:locale] != current_user.locale
  end
  
  def detect_locale
    return unless request.method == "GET"
    return if params[:locale]
    new_locale = current_user.locale if current_user
    new_locale = session[:locale] if session[:locale]
    #unless new_locale
    #  new_locale = request.compatible_language_from(I18n.available_locales.map(&:to_s))
    #  new_locale = I18n.default_locale.to_s unless new_locale
    #  flash[:locale] = t('notify_locale', :locale => new_locale)
    #end
    #return redirect_to replace_locale(new_locale)
    
    # TODO change back to original settings when we have multiple locales
    return redirect_to replace_locale('pt')
  end
  
  def replace_locale(new_locale)
    session[:locale] = new_locale
    new_url = "#{request.fullpath}"
    if params[:locale]
      new_url.gsub!(/^\/#{params[:locale]}/, "/#{new_locale}")
    else
      if new_url == "/"
        new_url = "/#{new_locale}"
      else
        new_url[0] = "/#{new_locale}/"
      end
    end
    new_url
  end
  
  def current_user
    return @current_user if @current_user
    if session[:user_id]
      return @current_user = User.find(session[:user_id])
    end
    if cookies[:remember_me_id] and cookies[:remember_me_hash]
      @current_user = User.find(cookies[:remember_me_id]) 
      @current_user = nil unless @current_user.remember_me_hash == cookies[:remember_me_hash]
      session[:user_id] = @current_user.id
    end
  rescue
    session[:user_id] = nil
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def require_condition(condition, message)
    unless condition
      flash[:failure] = message
      redirect_to :root
      false
    else
      true
    end
  end
  
  def require_login
    require_condition(current_user, t('require_login'))
  end
  
  def require_admin
    require_condition((can? :manage, :all), t('require_admin'))
  end

  def create_session_from_params
    if params[:sid]
      session_data = ActiveRecord::SessionStore::Session.find_by_session_id(params[:sid]).data
      session_data.each{ |k,v| session[k] = v }
    end
  end
end
