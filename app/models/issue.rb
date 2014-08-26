class Issue
  attr_reader   :number, :titie, :body, :created_at, :url, :assignee, :milestone, :state
  attr_accessor :labels

  def initialize
    @number     = 'Issue#'
    @title      = 'タイトル'
    @body       = '説明'
    @created_at = '登録日'
    @url        = 'URL'
    @assignee   = '担当者'
    @milestone  = 'マイルストーン'
    @state      = 'Status'
    @labels     = []
  end

  include Enumerable
  def each
    array = []
    array << @number << @title << @body << @created_at << @url << @assignee << @milestone << @state
    labels.each { |label| array << label }
    array.each do |element|
      yield element
    end
  end
end
