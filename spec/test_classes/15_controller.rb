class UsersController
  before_filter :find_user

  def show
  end

  private
  def find_user
    @user = User.find(params[:id])
  end
end
