require 'time'
require 'csv'

module IssuesHelper
  # オプションで生成されたラベルデータを扱いやすくする
  # オプションの生成ラベルリストのテキストデータを、配列データに変換する
  def generatedLabels_text_to_array(generated_labels_text)
    return [] if generated_labels_text.empty?
    generated_labels_array = []
    generated_labels_text.each_line do |line|
      line.chomp
      label_data = line.split(' ')
      label_name = label_data.first[1..-2]
      label_data.shift
      label_components = label_data
      generated_labels_array << GeneratedLabel.new(label_name, label_components)
    end
    return generated_labels_array
  end

  # ヘッダーのlabel部分を作成する
  def make_labels_list_in_header(labels_in_items, labels_in_items_new, labels_priority)
    labels_priority.uniq!
    labels_list_in_header = labels_in_items + labels_in_items_new
    labels_list_in_header.sort! do |a, b|
      acnt, bcnt = 0, 0
      if labels_priority.include?(a)
        acnt -= labels_priority.length - labels_priority.find_index(a)
      end
      if labels_priority.include?(b)
        bcnt -= labels_priority.length - labels_priority.find_index(b)
      end
      acnt == bcnt ? a <=> b : acnt <=> bcnt
    end
    return labels_list_in_header
  end

  # ヘッダーを作成する
  def make_header(items_except_labels, labels_in_header)
    return items_except_labels + labels_in_header
  end

  # issueリストの情報を作成する。ただし、issueでpull requestでないもののみ
  def make_issues_list_in_csv(issues_list_from_github,
                              pull_requests_list_from_github,
                              items_except_labels,
                              labels_list_in_header,
                              labels_in_items_new,
                              generated_labels,
                              use_pull_requests, blank)
    issues_list_in_csv = []
    issues_list_from_github.each do |issue_fg|
      next if !use_pull_requests && pull_request?(issue_fg, pull_requests_list_from_github)
      issue_data = add_items_data(issue_fg, items_except_labels, blank)
      issue_data = add_labels_data(issue_data,
                                   issue_fg,
                                   labels_list_in_header,
                                   labels_in_items_new,
                                   generated_labels,
                                   blank)
      issues_list_in_csv << issue_data
    end
    return issues_list_in_csv
  end

  # issueがpull requestか判断する
  # make_issues_list_in_csvのヘルパー
  def pull_request?(issue, pull_requests_list)
    return false if pull_requests_list.size == 0
    return true if pull_requests_list.detect { |pr| pr[:number] == issue[:number] }
    return false
  end

  # 日本標準時(JST)に変換し、時刻のyyyy/mm/dd形式化
  # make_issues_list_in_csvのヘルパー
  def date_formalization(date_utc)
    date_jst = Time.parse(date_utc).getlocal('+09:00')
    ymd = date_jst.strftime('%Y/%m/%d')
    return ymd
  end

  # issue_data（label除く）を生成する
  # make_issues_list_in_csvのヘルパー
  def add_items_data(issue_fg, items_except_labels, blank)
    issue_data = {
        number:     issue_fg.number,
        title:      issue_fg.title,
        created_at: date_formalization(issue_fg.created_at),
        url:        issue_fg.html_url,
        assignee:   (issue_fg.assignee ? issue_fg.assignee.login : blank),
        milestone:  (issue_fg.milestone ? issue_fg.milestone.title : blank),
        state:      issue_fg.state,
    }
    delete_unnecessary_items_data(issue_data, items_except_labels)
    return issue_data
  end

  # issue_data（label除く）のなかみをoption_itemに含まれているもののみにする
  # make_issues_list_in_csvのヘルパー
  def delete_unnecessary_items_data(issue_data, option_items_except_labels)
    original_issue = Issue.new
    original_issue.each_with_index do |original_item, index|
      next if option_items_except_labels.include?(original_item)
      key_name = original_issue.instance_variables[index].to_s[1..-1]
      issue_data.delete(:"#{key_name}")
    end
    return
  end

  # issue_dataのlabel部分を作成する
  # make_issues_list_in_csvのヘルパー
  def add_labels_data(issue_data, issue_fg, labels_list_in_header,
                      labels_in_items_new, generated_labels, blank)
    labels_in_issue_fg = issue_fg.labels.map { |label| label.name }
    labels_list_in_header.each do |label_in_header|
      issue_data[:"#{label_in_header}"] = blank
      if labels_in_items_new.include?(label_in_header)
        # label_in_headerがオプションで生成されたlabelの場合
        idx = generated_labels.index { |label| label.name == label_in_header }
        labels_in_issue_fg.each do |label_in_issue_fg|
          next unless generated_labels[idx].components.include?(label_in_issue_fg)
          issue_data[:"#{label_in_header}"] = label_in_issue_fg
        end
      else
        # label_in_headerがオプションで生成されたlabelでない場合
        labels_in_issue_fg.each do |label_in_issue_fg|
          next unless label_in_header == label_in_issue_fg
          issue_data[:"#{label_in_header}"] = label_in_issue_fg
        end
      end
    end
    return issue_data
  end

  # ヘッダーとissueリストをCSV形式にする
  def make_csv(header, issues)
    issues = [{ avoid_error: 'No Issue' }] if issues.empty?
    option = { row_sep:       "\r\n",
               headers:       header,
               write_headers: true
             }
    csv_data = CSV.generate('', option) do |csv|
      issues.each { |line| csv << line.values }
    end
    return csv_data
  end
end
