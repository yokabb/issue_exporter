class IssuesController < ApplicationController
  def export
    csv = 'hoge'
    send_data csv, type: 'text/csv', disposition: 'attachment'
  end
end
