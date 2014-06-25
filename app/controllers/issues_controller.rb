class IssuesController < ApplicationController
  include IssuesHelper

  def export
    user = params[:user]
    repo = params[:repo]

    github = Github.new(oauth_token: current_user.access_token, auto_pagination: true)
    issues_list_open   = github.issues.list(user: user, repo: repo, state:'open')
    issues_list_closed = github.issues.list(user: user, repo: repo, state: 'closed')
    pull_requests_list_open   = github.pull_requests.list(user:user, repo:repo, state:'open')
    pull_requests_list_closed = github.pull_requests.list(user:user, repo:repo, state:'closed')
    labels_list = github.issues.labels.list(user: user, repo: repo)

    #labels_in_header作成
    labels_in_header = make_labels_in_header(labels_list)

    #header作成
    header = { number: "#番号",
                title: "タイトル",
             assignee: "担当者",
            milestone: "マイルストーン",
                state: "Status"}
    labels_in_header.each_with_index do |label, index|
      header[:"#{"label" + index.to_s}"] = label
    end

    #issues作成
    issues = Array.new
    issues_open   = make_issues_list_in_csv(issues_list_open,   pull_requests_list_open,   labels_in_header)
    issues_closed = make_issues_list_in_csv(issues_list_closed, pull_requests_list_closed, labels_in_header)
    issues = issues_open + issues_closed
    issues.sort!{ |a, b| a[:number] <=> b[:number] }

    #csv作成
    csv = make_csv(header, issues)

    #BOM
    csv.prepend("\xef\xbb\xbf")
    
    #send
    send_data csv, type: 'text/csv', disposition: 'attachment'
  end
end