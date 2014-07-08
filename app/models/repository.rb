class Repository
  def initialize(name, owner, has_issue)
    @name = name               # レポジトリの名前
    @owner = owner             # レポジトリの所有者
    @has_issue = has_issue     # レポジトリがissueをもっているか
  end
  attr_accessor :name, :owner, :has_issue
end
