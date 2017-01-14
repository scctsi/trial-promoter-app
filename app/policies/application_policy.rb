class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    ['administrator', 'read_only'].include? user.role
  end

  def show?
    if ['administrator', 'statistician', 'read_only'].include? user.role
      scope.where(:id => record.id).exists?
    end
  end

  def create?
    user.role.administrator?
  end

  def new?
    create?
  end

  def update?
    user.role.administrator?
  end

  def edit?
    update?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
