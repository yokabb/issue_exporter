class IssuesController < ApplicationController
  include IssuesHelper

  # CSVファイルをエクスポートする(ユーザーがレポジトリを選択した場合に呼ばれる)
  def export
    # 選択したレポジトリの名前と、その所有者の名前を取得する
    user = params[:user]
    repo = params[:repo]
    # フォームのパラメータを取得する
    labels_priority     = params[:label_pri_selects] ? params[:label_pri_selects] : []
    items_except_labels = params[:items] ? params[:items] : []
    labels_in_items     = params[:labels_in_items] ? params[:labels_in_items] : []
    labels_in_items_new = params[:labels_in_items_new] ? params[:labels_in_items_new] : []
    use_pull_requests   = params[:pull_request] == 'on' ? true : false
    blank               = params[:blank]
    new_labels_data     = params[:new_labels_output_data] ? params[:new_labels_output_data] : ''
    # オプションで生成されたラベルデータを扱いやすくする
    generated_labels    = generatedLabels_text_to_array(new_labels_data)

    # 選択したレポジトリ内のissueのリスト, pull requestのリスト, labelのリストをGithubから取得する
    github = Github.new(oauth_token: current_user.access_token, auto_pagination: true)
    issues_list_open   = github.issues.list(user: user, repo: repo, state: 'open')
    issues_list_closed = github.issues.list(user: user, repo: repo, state: 'closed')
    pull_requests_list_open   = github.pull_requests.list(user: user, repo: repo, state: 'open')
    pull_requests_list_closed = github.pull_requests.list(user: user, repo: repo, state: 'closed')

    # ヘッダーのlabel部分の表示に対する前処理を行う
    labels_list_in_header = make_labels_list_in_header(labels_in_items, labels_in_items_new, labels_priority)

    # ヘッダーを作成する
    header = make_header(items_except_labels, labels_list_in_header)

    # 本体（issueリスト）を作成する。ただし、#番号順
    issues_open = make_issues_list_in_csv(issues_list_open,
                                          pull_requests_list_open,
                                          items_except_labels,
                                          labels_list_in_header,
                                          labels_in_items_new,
                                          generated_labels,
                                          use_pull_requests,
                                          blank)
    issues_closed = make_issues_list_in_csv(issues_list_closed,
                                            pull_requests_list_closed,
                                            items_except_labels,
                                            labels_list_in_header,
                                            labels_in_items_new,
                                            generated_labels,
                                            use_pull_requests,
                                            blank)
    issues = issues_open + issues_closed
    issues.sort! { |a, b| a[:number] <=> b[:number] }

    # ヘッダーとissueリストをCSV形式にする
    csv = make_csv(header, issues)
    csv.prepend("\xef\xbb\xbf")

    # CSVファイルを出力する
    send_data csv, type: 'text/csv', disposition: 'attachment'
  end
end
