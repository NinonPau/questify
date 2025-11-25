class ApplicationPolicy
  attr_reader :user, :record # create automiticly 2 methode:
  # def user/record
      #@user/@record
    #end


  def initialize(user, record)
    @user = user# the policy need to know who ask

    @record = record# model instance you authorize. the policy need to know on what
  end



  # DEFAULTS
  # All forbidden
  # (except index, see below)


  def index?
    false #We return false by default because index authorization is NOT checked via `index?`.
    #For index actions, Pundit uses the Scope (Scope#resolve) instead of index?,
    #in the controller index we are using policy_scope(...)
  end

  def show?
    false #in the controller index we are using authorize @...
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end



  # SCOPE
  # Used in policy_scope()
  # MUST be overridden

  class Scope
    attr_reader :user, :scope

    # scope = model name (ex: Quest)
    # user  = current_user
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all   # default fallback
    end
  end

end
#authorize = can I access THIS record?
#policy_scope = which records can I see AT ALL?
