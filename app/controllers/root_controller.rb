class RootController < ApplicationController
  def index
    if logged_in?
	  github = Github.new :oauth_token => current_user.access_token
	  user_orgs_list = github.orgs.list
	  user_repos_list = github.repos.list

	  @orgs = Array.new
	  user_orgs_list.each{ |org| @orgs << org.login }

	  @repos = Array.new
	  user_repos_list.each{ |repo| @repos << repo.name }
      @orgs.each do |org|
        org_repos_list = github.repos.list org:org
        org_repos = Array.new
        org_repos_list.each{ |repo| @repos << repo.name }
      end
    end
  end
end
