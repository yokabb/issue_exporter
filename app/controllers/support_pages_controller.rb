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
    # Œë‚Á‚½ƒAƒNƒZƒX–hŽ~
    redirect_to root_path if !current_user || logged_in?
  end
end
