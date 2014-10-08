class SessionsController < ApplicationController
  # ユーザーをサインインさせ、ユーザー画面に移動させる
  # (サインインボタンを押した場合に呼ばれる)
  def create
    # ユーザーの情報をGithubから取得する
    auth = request.env['omniauth.auth']
    user = User.find_by(github_id: auth['uid'])

    # データベースにユーザーの情報がない場合は登録する
    user ||= create_user(auth)

    # ユーザーの情報を更新する
    update_user(user, auth)

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

  private

  # ユーザー登録
  def create_user(auth)
    user = User.new(github_id:      auth['uid'],
                    name:           auth['extra']['raw_info']['login'],
                    access_token:   auth['credentials']['token'],
                    approved_terms: false)
    user.save
    return user
  end

  # ユーザー更新
  def update_user(user, auth)
    # アクセストークン
    user.access_token = auth['credentials']['token']
    # 名前
    user.name = auth['extra']['raw_info']['login']
    # 最終ログイン時刻
    user.last_login_at = Time.now
    # 保存
    user.save
  end
end
