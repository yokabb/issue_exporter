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
    # ������A�N�Z�X�h�~
    redirect_to root_path if !current_user || logged_in?
  end
end
