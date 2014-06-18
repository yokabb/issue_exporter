class IssuesController < ApplicationController
  def export
    none = "-"
    user = params[:user]
    repo = params[:repo]
    github = Github.new(:oauth_token => current_user.access_token, auto_pagination: true)

    issues_list_open = github.issues.list(:user => user, :repo => repo)
    issues_list_closed = github.issues.list(:user => user, :repo => repo, state: 'closed')
    
    issues = Array.new
    issues_list_open.each do |issue|
      labels = Array.new
      issue.labels.each{ |label| labels << label.name }
      tmp = { number: issue.number, title: issue.title, assignee: (issue.assignee ? issue.assignee.login : none), milestone: (issue.milestone ? issue.milestone.title : none), state: issue.state, labels: labels}
      issues << tmp
    end
    issues_list_closed.each do |issue|
      labels = Array.new
      issue.labels.each{ |label| labels << label.name }
      tmp = { number: issue.number, title: issue.title, assignee: (issue.assignee ? issue.assignee.login : none), milestone: (issue.milestone ? issue.milestone.title : none), state: issue.state, labels: labels}
      issues << tmp
    end
    issues.sort!{ |a, b| a[:number] <=> b[:number] }

    csv = ""

    header = { number: "#番号", title: "タイトル", assignee: "担当者", milestone: "マイルストーン", state: "Status", labels: "ラベル"}
    header.each_with_index do |(key, value), index|
      csv += value
      csv += ',' unless index == header.size - 1
    end
    csv += "\n"

    issues.each do |issue|
      issue.each_with_index do |(key, value), index|
        if key == :labels
          if true #Label表示形式1
            value.each_with_index do |labels, i|
              str = labels.to_s
              str.each_char{ |ch| if ch == '"' then ch = '"' + '"'; end }
              csv += '"' + str + '"'
              csv += ',' unless i == value.size - 1
            end
          else #Label表示形式2
            value.each do |labels|
              str = labels.to_s
              str.each_char{ |ch| if ch == '"' then ch = '"' + '"'; end }
              csv += '"' + str + '"'
              csv += '/'
            end
            csv.slice!(csv.size-1)
          end
        else
          str = value.to_s
          str.each_char{ |ch| if ch == '"' then ch = '"' + '"'; end }
          csv += '"' + str + '"'
        end
        csv += ',' unless index == issue.size - 1
      end
      csv += "\n"
    end
    
    csv.prepend("\xef\xbb\xbf")
    send_data csv, type: 'text/csv', disposition: 'attachment'
  end
end
