class IssuesController < ApplicationController
  include IssuesHelper

  # CSVファイルをエクスポートする(ユーザーがレポジトリを選択した場合に呼ばれる)
  def export
    # 選択したレポジトリの名前と、その所有者の名前を取得する
    user = params[:user]
    repo = params[:repo]

    # 選択したレポジトリ内のissueのリスト, pull requestのリスト, labelのリストをGithubから取得する
    github = Github.new(oauth_token: current_user.access_token, auto_pagination: true)
    issues_list_open   = github.issues.list(user: user, repo: repo, state: 'open')
    issues_list_closed = github.issues.list(user: user, repo: repo, state: 'closed')
    pull_requests_list_open   = github.pull_requests.list(user: user, repo: repo, state: 'open')
    pull_requests_list_closed = github.pull_requests.list(user: user, repo: repo, state: 'closed')
    labels_list = github.issues.labels.list(user: user, repo: repo)

    # ヘッダーのlabel部分の表示に対する前処理を行う
    labels_in_header = make_labels_in_header(labels_list)

    # ヘッダーを作成する
    header = { number:    'issue#',
               title:     'タイトル',
               assignee:  '担当者',
               milestone: 'マイルストーン',
               state:     'Status'
             }
    labels_in_header.each_with_index do |label, index|
      header[:"#{'label' + index.to_s}"] = label
    end

    # 本体（issueリスト）を作成する。ただし、#番号順
    issues_open   = make_issues_list_in_csv(issues_list_open,   pull_requests_list_open,   labels_in_header)
    issues_closed = make_issues_list_in_csv(issues_list_closed, pull_requests_list_closed, labels_in_header)
    issues = issues_open + issues_closed
    issues.sort! { |a, b| a[:number] <=> b[:number] }

    # ヘッダーとissueリストをCSV形式にする
    csv = make_csv(header, issues)
    csv.prepend("\xef\xbb\xbf")

    # CSVファイルを出力する
    send_data csv, type: 'text/csv', disposition: 'attachment'
  end
end
