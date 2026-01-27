class FellowshipsController < ApplicationController
  before_action :set_fellowship, only: [:update, :destroy]

  # GET /fellowships
  def index
    authorize Fellowship
    # check authorization via policy scope
    @fellowships = policy_scope(Fellowship)

    # separation for the view( built in the model definitions)
    @accepted_fellowships = @fellowships.accepted
    @pending_sent = @fellowships.pending.where(user: current_user)
    @pending_received = @fellowships.pending.where(user_ally_id: current_user.id)
  end

  # POST /fellowships
  def create
    # Even if the invited user does not exist, the create action is still authorized, 
    # so Pundit does not raise an error and the request can safely be rejected with a user-friendly message. 
    authorize Fellowship # not @fellowship because it is not yet built 
    # “Is the current user allowed to create a Fellowship in general?”
    
    # Find the user to invite using the username provided in the form
    ally = User.find_by(username: params[:ally_username])

    # If no user is found, redirect back with an error message
    # and stop the execution to avoid creating an invalid fellowship
    unless ally
      redirect_to fellowships_path, alert: "User not found"
      return
    end

    # Build a new fellowship request
    # - current_user is the sender of the invitation
    # - ally is the receiver of the invitation
    # - status is set to "pending" until the receiver responds
    @fellowship = Fellowship.new(
      user: current_user,
      ally: ally,
      status: "pending"
    )

    

    # Try to save the fellowship request
    if @fellowship.save
      # Success: redirect back with a confirmation message
      redirect_to fellowships_path, notice: "Fellowship request sent"
    else
      # Failure: redirect back with an error message
      redirect_to fellowships_path, alert: "Failed request"
    end
  end


  # PATCH /fellowships/:id
  def update
    authorize @fellowship

    # Only the receiver can accept or decline a request (helper method below)
    unless receiver? 
      redirect_to fellowships_path, alert: "Not authorized"
      return
    end

    if @fellowship.update(status: params[:status])
      redirect_to fellowships_path, notice: "Fellowship updated"
    else
      redirect_to fellowships_path, alert: "Update failed"
    end
  end

  # DELETE /fellowships/:id
  def destroy
    authorize @fellowship
    @fellowship.destroy

    redirect_to fellowships_path, notice: "Fellowship removed"
  end

  private
  #Rails automatically loads the correct fellowship based on the :id with the before_action
  def set_fellowship
    @fellowship = Fellowship.find(params[:id])
  end

  # Current user is the receiver of the request
  def receiver?
    @fellowship.user_ally_id == current_user.id
  end
end
