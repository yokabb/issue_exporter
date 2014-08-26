require 'time'
require 'csv'

module IssuesHelper
  # オプションの生成ラベルリストのテキストデータを、配列に変換する
  def generatedLabels_text_to_array(generated_labels_textdata)
    return [] if generated_labels_textdata.empty?
    generated_labels_array = []
    generated_labels_textdata.each_line do |line|
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
  def make_labels_in_header(labels_in_items, labels_in_items_new, label_priority)
    label_priority.uniq!
    labels_in_header = labels_in_items + labels_in_items_new
    labels_in_header.sort! do |a, b|
      acnt, bcnt = 0, 0
      if label_priority.include?(a)
        acnt -= label_priority.length - label_priority.find_index(a)
      end
      if label_priority.include?(b)
        bcnt -= label_priority.length - label_priority.find_index(b)
      end
      acnt == bcnt ? a <=> b : acnt <=> bcnt
    end
    return labels_in_header
  end

  # ヘッダーを作成する
  def make_header(items_except_labels, labels_in_header)
    return items_except_labels + labels_in_header
  end

  # issueリストを作成する
  def make_issue_list_in_csv(issue_list_from_github,
                             pull_request_list_from_github,
                             items_except_labels,
                             labels_in_header,
                             labels_in_items_new,
                             generated_labels,
                             use_pull_request,
                             blank)
    issue_list_in_csv = []
    issue_list_from_github.each do |issue_from_github|
      next if !use_pull_request && pull_request?(issue_from_github, pull_request_list_from_github)
      issue_data = add_item_data_except_label_data(issue_from_github, items_except_labels, blank)
      issue_data = add_label_data(issue_data,
                                  issue_from_github,
                                  labels_in_header,
                                  labels_in_items_new,
                                  generated_labels,
                                  blank)
      issue_list_in_csv << issue_data
    end
    return issue_list_in_csv
  end

  # issueがpull requestか判断する
  # make_issue_list_in_csvのヘルパー
  def pull_request?(issue_from_github, pull_request_list_from_github)
    return false if pull_request_list_from_github.size == 0
    return true if pull_request_list_from_github.detect do |pull_request_from_github| 
      pull_request_from_github[:number] == issue_from_github[:number]
    end
    return false
  end

  # 日本標準時(JST)に変換し、時刻のyyyy/mm/dd形式化をする
  # make_issue_list_in_csvのヘルパー
  def date_formalization(date_utc)
    date_jst = Time.parse(date_utc).getlocal('+09:00')
    ymd = date_jst.strftime('%Y/%m/%d')
    return ymd
  end

  # issue_data（label除く）を生成する
  # make_issue_list_in_csvのヘルパー
  def add_item_data_except_label_data(issue_from_github, items_except_labels, blank)
    item_data_except_label_data = {
        number:     issue_from_github.number,
        title:      issue_from_github.title,
        body:       (issue_from_github.body ? issue_from_github.body : blank),
        created_at: date_formalization(issue_from_github.created_at),
        url:        issue_from_github.html_url,
        assignee:   (issue_from_github.assignee ? issue_from_github.assignee.login : blank),
        milestone:  (issue_from_github.milestone ? issue_from_github.milestone.title : blank),
        state:      issue_from_github.state,
    }
    delete_unnecessary_item_data(item_data_except_label_data, items_except_labels)
    return item_data_except_label_data
  end

  # issue_data（label除く）のなかみをoption_items（label除く）に含まれているもののみにする
  # make_issue_list_in_csvのヘルパー
  def delete_unnecessary_item_data(item_data_except_label_data, option_items_except_labels)
    original_issue = Issue.new
    original_issue.each_with_index do |original_item, index|
      next if option_items_except_labels.include?(original_item)
      key_name = original_issue.instance_variables[index].to_s[1..-1]
      item_data_except_label_data.delete(:"#{key_name}")
    end
    return
  end

  # issue_data（label部分）を作成する
  # make_issue_list_in_csvのヘルパー
  def add_label_data(issue_data, issue_from_github, labels_in_header,
                      labels_in_items_new, generated_labels, blank)
    labels_in_issue_from_github = issue_from_github.labels.map { |label| label.name }
    labels_in_header.each do |label_in_header|
      issue_data[:"#{label_in_header}"] = blank
      if labels_in_items_new.include?(label_in_header)
        # label_in_headerがオプションで生成されたlabelの場合
        idx = generated_labels.index { |label| label.name == label_in_header }
        labels_in_issue_from_github.each do |label_in_issue_from_github|
          next unless generated_labels[idx].components.include?(label_in_issue_from_github)
          issue_data[:"#{label_in_header}"] = label_in_issue_from_github
        end
      else
        # label_in_headerがオプションで生成されたlabelでない場合
        labels_in_issue_from_github.each do |label_in_issue_from_github|
          next unless label_in_header == label_in_issue_from_github
          issue_data[:"#{label_in_header}"] = label_in_issue_from_github
        end
      end
    end
    return issue_data
  end

  # openのissueリストとclosedのissueリストを合わせる
  def merge_issue_list(issue_list_open, issue_list_closed)
    issue_list = issue_list_open + issue_list_closed
    issue_list.sort! { |a, b| a[:number] <=> b[:number] }
    return issue_list
  end

  # ヘッダーとissueリストをCSV形式にする
  def make_csv(header, issue_list)
    issue_list = [{ avoid_error: 'No Issue' }] if issue_list.empty?
    option = { row_sep:       "\r\n",
               headers:       header,
               write_headers: true
             }
    csv_data = CSV.generate('', option) do |csv|
      issue_list.each { |line| csv << line.values }
    end
    return csv_data
  end
end
