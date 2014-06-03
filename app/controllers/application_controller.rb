class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include PublicActivity::StoreController
  protect_from_forgery with: :exception
  before_filter :user_tracking_code

  include PublicActivity::StoreController

private
  
  def user_tracking_code
    if !cookies.permanent.signed[:tracking_code].present?
      tracking_code = Digest::MD5.hexdigest(DateTime.now().to_s+request.remote_ip.to_s)

      cookies.permanent.signed[:tracking_code] = {
        value: tracking_code
      }
    end
  end

  def require_login
    redirect_to login_url, alert: "You must first log in or sign up." if current_user.nil?
  end
end
