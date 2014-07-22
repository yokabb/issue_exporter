require 'time'
require 'csv'

module IssuesHelper
  # ヘッダーのlabel部分の表示に対する前処理を行う
  # labelのカテゴリ内の重複をなくし(pri: high, pri: low は pri:に統一)、
  # ユーザーにとって重要なlabelを左側に表示するためにソートする
  def make_labels_in_header(labels_list)
    labels_in_header = []
    labels_list.each do |label_in_repo|
      colon_p = (label_in_repo.name + ':').index(':')
      label_name = label_in_repo.name[0..colon_p]
      already_in_list = labels_in_header.detect { |label_in_array| label_in_array == label_name }
      next if already_in_list
      labels_in_header << label_name
    end
    labels_in_header.sort! do |a, b|
      x = a.include?(':') ? -1 : 1
      y = b.include?(':') ? -1 : 1
      x -= 1 if a.include?('type') || a.include?('pri')
      y -= 1 if b.include?('type') || b.include?('pri')
      x == y ? a <=> b : x <=> y
    end
    return labels_in_header
  end

  # issueリストの情報を作成する。ただし、issueでpull requestでないもののみ
  def make_issues_list_in_csv(issues_list_from_github, pull_requests_list_from_github, labels_in_header)
    none = '-'
    issues_list_in_csv = []
    issues_list_from_github.each do |issue_fg|
      next if pull_request?(issue_fg, pull_requests_list_from_github)
      tmp = { number:     issue_fg.number,
              title:      issue_fg.title,
              created_at: date_formalization(issue_fg.created_at),
              url:        issue_fg.html_url,
              assignee:   (issue_fg.assignee ? issue_fg.assignee.login : none),
              milestone:  (issue_fg.milestone ? issue_fg.milestone.title : none),
              state:      issue_fg.state,
            }
      make_labels_in_issue(tmp, issue_fg, labels_in_header, none)
      issues_list_in_csv << tmp
    end
    return issues_list_in_csv
  end

  # issueがpull requestか判断する
  # ↑のmake_issues_list_in_csv メソッドのヘルパー
  def pull_request?(issue, pull_requests_list)
    return false if pull_requests_list.size == 0
    return true if pull_requests_list.detect { |pr| pr[:number] == issue[:number] }
    return false
  end

  # 日本標準時(JST)に変換し、時刻のyyyy/mm/dd形式化
  # ↑のmake_issues_list_in_csv メソッドのヘルパー
  def date_formalization(date_utc)
    date_jst = Time.parse(date_utc).getlocal('+09:00')
    ymd = date_jst.strftime('%Y/%m/%d')
    return ymd
  end

  # issueのlabel部分を作成する
  # ↑のmake_issues_list_in_csv メソッドのヘルパー
  def make_labels_in_issue(issue, issue_fg, labels_in_header, none)
    labels_in_header.each_with_index do |label_in_header, index|
      issue[:"#{'label' + index.to_s}"] = none
      issue_fg.labels.each do |label_in_issue_fg|
        next unless label_in_issue_fg.name.include?(label_in_header)
        issue[:"#{'label' + index.to_s}"] = if label_in_issue_fg.name.include?(':')
                                              colon_p = (label_in_issue_fg.name).index(':')
                                              label_in_issue_fg.name[(colon_p + 1)..-1]
                                            else
                                              label_in_issue_fg.name
                                            end
        break
      end
    end
    return issue
  end

  # ヘッダーとissueリストをCSV形式にする
  def make_csv(header, issues)
    option = { row_sep:       "\r\n",
               headers:       header.values,
               write_headers: true
             }
    csv_data = CSV.generate('', option) do |csv|
      issues.each { |line| csv << line.values }
    end
    return csv_data
  end
end
