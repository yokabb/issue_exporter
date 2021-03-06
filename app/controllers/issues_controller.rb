class IssuesController < ApplicationController
  include IssuesHelper

  # CSVファイルをエクスポートする(ユーザーがレポジトリを選択した場合に呼ばれる)
  def export
    # 選択したレポジトリの名前と、その所有者の名前を取得する
    user = params[:user]
    repo = params[:repo]
    # フォームのパラメータを取得する
    label_priority       = params[:label_pri_selects] ? params[:label_pri_selects] : []
    items_except_labels  = params[:items] ? params[:items] : []
    labels_in_items      = params[:labels_in_items] ? params[:labels_in_items] : []
    labels_in_items_new  = params[:labels_in_items_new] ? params[:labels_in_items_new] : []
    use_pull_request     = params[:pull_request] == 'on' ? true : false
    use_issue_open       = params[:issue_open_closed].include?('open')
    use_issue_closed     = params[:issue_open_closed].include?('closed')
    use_issue_date_range = params[:issue_date_range] == 'date_range'
    issue_date_start     = params[:issue_date_range_input] ? params[:issue_date_range_input].split.first : nil
    issue_date_end       = params[:issue_date_range_input] ? params[:issue_date_range_input].split.last : nil
    blank                = params[:blank]
    generated_labels_textdata = params[:generated_labels_textdata] ? params[:generated_labels_textdata] : ''
    # オプションの生成ラベルリストのテキストデータを、配列に変換する
    generated_labels    = generated_labels_text_to_array(generated_labels_textdata)

    # 選択したレポジトリ内のissueのリスト, pull requestのリストをGithubから取得する
    github = Github.new(oauth_token: current_user.access_token, auto_pagination: true)
    issue_list_open_from_github   = github.issues.list(user: user, repo: repo, state: 'open')
    issue_list_closed_from_github = github.issues.list(user: user, repo: repo, state: 'closed')
    pull_request_list_open_from_github   = github.pull_requests.list(user: user, repo: repo, state: 'open')
    pull_request_list_closed_from_github = github.pull_requests.list(user: user, repo: repo, state: 'closed')

    # ヘッダーのlabel部分を作成する
    labels_in_header = make_labels_in_header(labels_in_items, labels_in_items_new, label_priority)

    # ヘッダーを作成する
    header = make_header(items_except_labels, labels_in_header)

    # issueリストを作成する
    issue_list_open = []
    issue_list_closed = []
    if use_issue_open
      issue_list_open = make_issue_list_in_csv(issue_list_open_from_github,
                                               pull_request_list_open_from_github,
                                               items_except_labels,
                                               labels_in_header,
                                               labels_in_items_new,
                                               generated_labels,
                                               use_pull_request,
                                               use_issue_date_range,
                                               issue_date_start,
                                               issue_date_end,
                                               blank)
    end
    if use_issue_closed
      issue_list_closed = make_issue_list_in_csv(issue_list_closed_from_github,
                                                 pull_request_list_closed_from_github,
                                                 items_except_labels,
                                                 labels_in_header,
                                                 labels_in_items_new,
                                                 generated_labels,
                                                 use_pull_request,
                                                 use_issue_date_range,
                                                 issue_date_start,
                                                 issue_date_end,
                                                 blank)
    end
    issue_list = merge_issue_list(issue_list_open, issue_list_closed)

    # ヘッダーとissueリストをCSV形式にする
    csv_data = make_csv(header, issue_list)
    csv_data.prepend("\xef\xbb\xbf")

    # CSVファイルを出力する
    send_data csv_data, type: 'text/csv', disposition: 'attachment'
  end
end
