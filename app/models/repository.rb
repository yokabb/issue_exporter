class Repository
  def initialize(name, owner)
    @name = name               # レポジトリの名前
    @owner = owner             # レポジトリの所有者
    
    # has_issue = github.repos.get(user: owner, repo: name).has_issuesしたいが
    # .get すると .listがなぜかバグるため、保留
    # @has_issue = has_issue     # レポジトリがissueをもっているか
  end
  attr_accessor :name, :owner, :has_issue
end
