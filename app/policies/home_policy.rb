class HomePolicy < Struct.new(:user, :home)
  def index?
    ['administrator', 'read_only', 'statistician'].include? user.role
  end
end