class RootController < ApplicationController
  def index
    if logged_in?
      github = Github.new :oauth_token => current_user.access_token
      user_orgs_list = github.orgs.list
      user_repos_list = github.repos.list

      @orgs = Array.new
      user_orgs_list.each{ |org| @orgs << org.login }

      @repos = Array.new
      @users = Array.new
      user_repos_list.each do |repo|
        @repos << repo.name
        @users << github.users.get(id: current_user.github_id).login
      end
      @orgs.each do |org|
        org_repos_list = github.repos.list org:org
        org_repos_list.each do |repo|
          @repos << repo.name
          @users << org
        end
      end
    end
  end
end
