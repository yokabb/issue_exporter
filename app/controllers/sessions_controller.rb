class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    user = User.find_by(github_id: auth["uid"])
    if !user
      user = User.new(github_id: auth["uid"], access_token: auth["credentials"]["token"])
      user.save
    end
    if user.access_token != auth["credentials"]["token"]
      user.access_token = auth["credentials"]["token"]
      user.save
    end
    
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end

end
