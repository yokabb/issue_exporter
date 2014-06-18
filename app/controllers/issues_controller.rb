class IssuesController < ApplicationController
  def export
    none = "-"
    user = params[:user]
    repo = params[:repo]

    github = Github.new(:oauth_token => current_user.access_token, auto_pagination: true)
# debug用
#    github = Github.new(:oauth_token => current_user.access_token)
#    binding.pry
    
    issues_list_open = github.issues.list(:user => user, :repo => repo, state:'open')
    issues_list_closed = github.issues.list(:user => user, :repo => repo, state: 'closed')

    pull_requests_list_open = github.pull_requests.list(user:user, repo:repo, state:'open')
    pull_requests_list_closed = github.pull_requests.list(user:user, repo:repo, state:'closed')

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
    labels_list.sort!{ |a, b|
      x = a.include?(":") ? -1 : 1
      y = b.include?(":") ? -1 : 1
      x = x - 1 if a.include?("type") || a.include?("pri")
      y = y - 1 if b.include?("type") || b.include?("pri")
      x == y ? a <=> b : x <=> y
    }

    #header作成
    header = { number: "#番号", title: "タイトル", assignee: "担当者", milestone: "マイルストーン", state: "Status"}
    labels_list.each_with_index do |label, index|
      header[:"#{"Label" + index.to_s}"] = label
    end

    #issues作成
    issues = Array.new
    2.times do |i|
      issues_list = issues_list_open
      issues_list = issues_list_closed if i == 0 
      
      issues_list.each do |issue|
        #pull_requestsに属するもの排除
        next if (pull_requests_list_open.find{|pr| pr.number == issue.number} || pull_requests_list_closed.find{|pr| pr.number == issue.number})

        labels = Array.new(labels_list.size, none)
        labels_list.each_with_index do |label_in_list, index|
          issue.labels.each do |label_in_issue|
            if label_in_issue.name.include?(label_in_list)
              labels[index] = if label_in_issue.name.include?(":")
                                colon_p = (label_in_issue.name).index(":")
                                labels[index] = label_in_issue.name[(colon_p + 1)..-1]
                              else
                                label_in_issue.name
                              end
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
