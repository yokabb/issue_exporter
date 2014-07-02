class RootController < ApplicationController
  # ログイン画面（ユーザーはサインインしていない場合）
  # ユーザー画面（ユーザーはサインイン済の場合）
  def index
    return unless logged_in?

    # ユーザーの所属組織のリストとユーザーのレポジトリのリストをGithubから取得する
    github = Github.new(oauth_token: current_user.access_token)
    user_orgs_list  = github.orgs.list
    user_repos_list = github.repos.list

    # 組織のリストから組織の名前のみを取り出す
    @orgs = []
    user_orgs_list.each { |org| @orgs << org.login }

    # ユーザーが参照可能なすべてのレポジトリの名前と、
    # 各レポジトリの所有者（ユーザーまたは組織）の名前を保持する
    # ユーザーがownerのレポジトリ、ユーザーがcollaboratorのレポジトリ、
    # ユーザーのorgnizationのレポジトリの順
    # (@repos[i]の所有者は@users[i])
    @repos = []
    @users = []
    user_repos_list.each do |repo|
      next if repo.owner.login != github.users.get(id: current_user.github_id).login
      @repos << repo.name
      @users << repo.owner.login
    end
    user_repos_list.each do |repo|
      next unless repo.owner.login != github.users.get(id: current_user.github_id).login
      @repos << repo.name
      @users << repo.owner.login
    end
    @orgs.each do |org|
      org_repos_list = github.repos.list(org: org)
      org_repos_list.each do |repo|
        @repos << repo.name
        @users << org
      end
    end

    render 'userpage'
  end
end
