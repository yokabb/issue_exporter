class SupportPagesController < ApplicationController
  def about
  end

  def privacy
  end

  def terms
  end

  def contact
  end

  def approval
    # 誤ったアクセス防止
    redirect_to root_path if !current_user || logged_in?
  end
end
