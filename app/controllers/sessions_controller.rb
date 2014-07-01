class SessionsController < ApplicationController
  # ユーザーをサインインさせ、ユーザー画面に移動させる
  # (サインインボタンを押した場合に呼ばれる)
  def create
    # ユーザーの情報をGithubから取得する
    auth = request.env['omniauth.auth']
    user = User.find_by(github_id: auth['uid'])

    # データベースにユーザーの情報がない場合は登録する
    unless user
      user = User.new(github_id: auth['uid'], access_token: auth['credentials']['token'])
      user.save
    end

    # ユーザーの情報が更新されていた場合は更新する
    if user.access_token != auth['credentials']['token']
      user.access_token = auth['credentials']['token']
      user.save
    end

    session[:user_id] = user.id
    redirect_to '/userpage'
  end

  # ユーザーをサインアウトさせ、サインイン画面に戻す
  # (サインアウトボタンを押した場合に呼ばれる)
  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
