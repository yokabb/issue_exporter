class SessionsController < ApplicationController
  # ユーザーをサインインさせ、ユーザー画面に移動させる
  # (サインインボタンを押した場合に呼ばれる)
  def create
    # ユーザーの情報をGithubから取得する
    auth = request.env['omniauth.auth']
    user = User.find_by(github_id: auth['uid'])

    # データベースにユーザーの情報がない場合は登録する
    unless user
      user = User.new(github_id: auth['uid'], access_token: auth['credentials']['token'], approved_terms: false)
      user.save
    end

    # ユーザーのアクセストークンの情報が更新されていた場合は更新する
    if user.access_token != auth['credentials']['token']
      user.access_token = auth['credentials']['token']
      user.save
    end

    # セッションの確立
    session[:user_id] = user.id

    # ユーザーが利用規約を承認している場合は、ユーザー画面へ
    # 承認していない場合は、利用規約承認画面へ
    if user.approved_terms
      redirect_to root_path
    else
      redirect_to '/support_pages/approval'
    end
  end

  # ユーザーをサインアウトさせ、サインイン画面に戻す
  # (サインアウトボタンを押した場合に呼ばれる)
  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
