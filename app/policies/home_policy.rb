class HomePolicy < Struct.new(:user, :home)
  def index?
    false
    # ['administrator', 'read_only', 'statistician'].include? user.role
  end
end