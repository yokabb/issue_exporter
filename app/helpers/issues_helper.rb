module IssuesHelper
  #header部分に該当するlabels_listをカテゴリ左側に優先の順で作成（カテゴリ重複なし）
  def make_labels_in_header(labels_list)
    labels_in_header = Array.new
    labels_list.each do |label_in_repo|
      colon_p = (label_in_repo.name + ":").index(":")
      label_name = label_in_repo.name[0..colon_p]
      if labels_in_header.find{ |label_in_array| label_in_array == label_name } == nil
        labels_in_header << label_name
      end
    end
    labels_in_header.sort!{ |a, b|
      x = a.include?(":") ? -1 : 1
      y = b.include?(":") ? -1 : 1
      x = x - 1 if a.include?("type") || a.include?("pri")
      y = y - 1 if b.include?("type") || b.include?("pri")
      x == y ? a <=> b : x <=> y
    }
    return labels_in_header
  end

  #issues_list_from_github内でpull_requests_list_from_githubに属さないissueで
  #issue_list_in_csvを作成。ただし、labelのカテゴリ重複なし
  def make_issues_list_in_csv(issues_list_from_github, pull_requests_list_from_github, labels_in_header)
    none = "-"
    issues_list_in_csv = Array.new
    issues_list_from_github.each do |issue_fg|
      next if (pull_requests_list_from_github.size != 0 && pull_requests_list_from_github.find{|pr| pr.number == issue_fg.number})
      tmp = { number: issue_fg.number,
               title: issue_fg.title,
            assignee: (issue_fg.assignee ? issue_fg.assignee.login : none),
           milestone: (issue_fg.milestone ? issue_fg.milestone.title : none),
               state: issue_fg.state,
            }
      labels = Array.new(labels_in_header.size, none)
      labels_in_header.each_with_index do |label_in_header, index|
        issue_fg.labels.each do |label_in_issue_fg|
          if label_in_issue_fg.name.include?(label_in_header)
            labels[index] = if label_in_issue_fg.name.include?(":")
                              colon_p = (label_in_issue_fg.name).index(":")
                              label_in_issue_fg.name[(colon_p + 1)..-1]
                            else
                              label_in_issue_fg.name
                            end
            break
          end
        end
      end
      labels_in_header.each_with_index do |la, index|
        tmp[:"#{"Label" + index.to_s}"] = labels[index]
      end
      issues_list_in_csv << tmp
    end
    return issues_list_in_csv
  end

  #header, issuesからcsv作成
  def make_csv(header, issues)
    csv = ""
    header.each_with_index do |(key, value), index|
      csv += value
      csv += ',' unless index == header.size - 1
    end
    csv += "\n"
    issues.each do |issue|
      issue.each_with_index do |(key, value), index|
        str = value.to_s
        str.each_char{ |ch| if ch == '"' then ch = '"' + '"'; end }
        csv += '"' + str + '"'
        csv += ',' unless index == issue.size - 1
      end
      csv += "\n"
    end
    return csv
  end
end
