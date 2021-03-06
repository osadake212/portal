class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def show
    @user = User.find(params[:id])
    if current_user? @user
      @micropost = current_user.microposts.build
      @feeds = Micropost.from_users_followed_by(@user)
    else
      @feeds = @user.microposts
    end
  end

  def new
    @user = User.new()
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Portal"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page], per_page: 10)
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page], per_page: 10)
    render 'show_follow'
  end

  private 
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # ----- before actions -----
    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user? @user
    end

end
