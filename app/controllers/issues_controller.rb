class IssuesController < ApplicationController
  def export
    none = "-"
    user = params[:user]
    repo = params[:repo]

    github = Github.new(:oauth_token => current_user.access_token, auto_pagination: true)
    
    issues_list_open = github.issues.list(:user => user, :repo => repo)
    issues_list_closed = github.issues.list(:user => user, :repo => repo, state: 'closed')

    #labels配列の作成(重複カテゴリは集約)
    labels_list = Array.new
    github.issues.labels.list(user: user, repo: repo).each do |label_in_repo|
      colon_p = (label_in_repo.name + ":").index(":")
      label_name = label_in_repo.name[0..colon_p]
      if labels_list.find{ |label_in_array| label_in_array == label_name } == nil
        labels_list << label_name
      end
    end
    labels_list.sort!

    #header作成
    header = { number: "#番号", title: "タイトル", assignee: "担当者", milestone: "マイルストーン", state: "Status"}
    labels_list.each_with_index do |label, index|
      header[:"#{"Label" + index.to_s}"] = label
    end

    #issuesの作成
    issues = Array.new
    2.times do |i|
      issues_list = issues_list_open
      issues_list = issues_list_closed if i == 0 
      
      issues_list.each do |issue|
        labels = Array.new(labels_list.size, none)
        labels_list.each_with_index do |label_in_list, index|
          issue.labels.each do |label_in_issue|
            if label_in_issue.name.include?(label_in_list)
              labels[index] = label_in_issue.name
              break
            end
          end
        end
        
        tmp = { number: issue.number,
                 title: issue.title,
              assignee: (issue.assignee ? issue.assignee.login : none),
             milestone: (issue.milestone ? issue.milestone.title : none),
                 state: issue.state,
              }
        labels_list.each_with_index do |label, index|
          tmp[:"#{"Label" + index.to_s}"] = labels[index]
        end
        
        issues << tmp
      end
    end
    issues.sort!{ |a, b| a[:number] <=> b[:number] }

    #csv作成
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
    
    #BOM
    csv.prepend("\xef\xbb\xbf")
    
    #send
    send_data csv, type: 'text/csv', disposition: 'attachment'
  end
end
