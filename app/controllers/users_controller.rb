# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    unless current_user.admin? || current_user.moderator?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to root_path
    else
      @users = User.all
    end
  end

  def show
    unless current_user.admin? || current_user.moderator? || current_user == @user
      flash[:alert] = "You are not authorized to view this user."
      redirect_to root_path
    end
  end

  def edit
    unless current_user.admin?
      flash[:alert] = "You are not authorized to edit this user."
      redirect_to root_path
    end
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User deleted successfully.'
  end


  private

  def set_user
    @user = User.find(params[:id])
  end


  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end