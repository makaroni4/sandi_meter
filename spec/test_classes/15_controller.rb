class UsersController
  before_filter :find_user

  def show
  end

  private
  def find_user
    @user = User.find(params[:id])
  end

  protected
  def protected_find_user
    @user = User.find(params[:id])
  end

  public
  def create
    @user = User.new(params[:user])
  end
end
