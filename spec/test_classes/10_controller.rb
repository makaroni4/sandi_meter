class AnotherUsersController
  def index
    @users = User.page(params[:page])
    @excess_variable = 'blah blah'
  end
end
