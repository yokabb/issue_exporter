class RootController < ApplicationController
  def index
    if logged_in?
	  github = Github.new :oauth_token => current_user.access_token
	  user_orgs_list = github.orgs.list
	  user_repos_list = github.repos.list

	  @orgs = Array.new
	  user_orgs_list.each{|org| @orgs << org.login}

	  @my_repos = Array.new
	  user_repos_list.each{|repo| @my_repos << repo.name}

      @orgs_repos = Array.new
      @orgs.each do |org|
        org_repos_list = github.repos.list org:org
        org_repos = Array.new
        org_repos_list.each{|repo| org_repos << repo.name}
        @orgs_repos << org_repos
      end
	end
  end
end
