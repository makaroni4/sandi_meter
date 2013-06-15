class User
  def initialize
    @name = Faker::Lorem.word
  end

  def hi
    puts @name
  end
end
