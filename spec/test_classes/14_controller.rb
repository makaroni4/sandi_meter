class GuestController
  def create_guest_user
    u = User.new_guest
    u.save
    session[:guest_user_id] = u.id
    u
  end
end
