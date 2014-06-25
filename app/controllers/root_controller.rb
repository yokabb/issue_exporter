class RootController < ApplicationController
  def index
  end

  def userpage
    github = Github.new(oauth_token: current_user.access_token)
    user_orgs_list  = github.orgs.list
    user_repos_list = github.repos.list

    @orgs = []
    user_orgs_list.each { |org| @orgs << org.login }

    @repos = []
    @users = []
    user_repos_list.each do |repo|
      @repos << repo.name
      @users << github.users.get(id: current_user.github_id).login
    end
    @orgs.each do |org|
      org_repos_list = github.repos.list(org: org)
      org_repos_list.each do |repo|
        @repos << repo.name
        @users << org
      end
    end
  end
end
