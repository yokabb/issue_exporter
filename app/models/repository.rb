class Repository
  attr_reader :name, :owner, :has_issue
  def initialize(name, owner, has_issue)
    @name = name               # レポジトリの名前
    @owner = owner             # レポジトリの所有者
    @has_issue = has_issue     # レポジトリがissueをもっているか
  end
end
