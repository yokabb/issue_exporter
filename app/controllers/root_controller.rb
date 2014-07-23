class RootController < ApplicationController
  # ログイン画面（ユーザーはサインインしていない場合）
  # ユーザー画面（ユーザーはサインイン済の場合）
  def index
    return unless logged_in?

    # ユーザーの所属組織のリストと
    # ユーザーと共同者のレポジトリのリストをGithubから取得する
    github = Github.new(oauth_token: current_user.access_token)
    @username = github.users.get(id: current_user.github_id).login
    @colls = []
    @orgs = []
    @repos = []
    user_orgs_list  = github.orgs.list
    user_repos_list = github.repos.list

    # 協力者の名前のリストの生成
    user_repos_list.each do |repo|
      next if repo.owner.login == @username
      next if @colls.include?(repo.owner.login)
      @colls << repo.owner.login
    end

    # 所属組織の名前のリストの生成
    user_orgs_list.each { |org| @orgs << org.login }

    # ユーザーが参照可能なすべてのレポジトリの名前と
    # 各レポジトリの所有者（ユーザーまたは組織）の名前を保持する
    # レポジトリの順は、
    # ユーザーがownerのもの、ユーザーがcollaboratorのもの、ユーザーのorgnizationのもの
    user_repos_list.each do |repo|
      add_repo(repo) if repo.owner.login == @username
    end
    user_repos_list.each do |repo|
      add_repo(repo) unless repo.owner.login == @username
    end
    @orgs.each do |org|
      org_repos_list = github.repos.list(org: org)
      org_repos_list.each do |repo|
        add_repo(repo)
      end
    end

    render 'userpage'
  end

  private

  def add_repo(repo)
    name = repo.name
    owner = repo.owner.login
    has_issue = repo.has_issues
    @repos << Repository.new(name, owner, has_issue)
  end
end
