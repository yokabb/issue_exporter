class OptionController < ApplicationController
  # 必要なissue情報を選択する
  def select
    # 選択したレポジトリの名前と、その所有者の名前を取得する
    @user = params[:user]
    @repo = params[:repo]

    # 選択したレポジトリ内のlabelのリストをGithubから取得する
    github = Github.new(oauth_token: current_user.access_token, auto_pagination: true)
    labels_list = github.issues.labels.list(user: @user, repo: @repo)

    # Issues項目を保持する
    @issues_items = Issue.new
    @issues_items.labels = labels_list.map { |label| label.name }.sort!
  end
end
