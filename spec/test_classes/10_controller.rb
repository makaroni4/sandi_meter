class AnotherUsersController
  def index
    @users = User.page(params[:page])
    @excess_variable = 'blah '
    @excess_variable = @excess_variable + 'blah'
  end
end
