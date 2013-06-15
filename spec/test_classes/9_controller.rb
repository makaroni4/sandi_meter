class UsersController
  def index
    @users = User.page(params[:page])
  end
end
