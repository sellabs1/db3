class UsersController < ApplicationController
  #applies the set_headers method before performing other methods
  before_filter :set_headers

  # GET /users
  # GET /users.json
    def index
        @users = User.all

        render json: @users
    end

        def create
            @user = User.new
            @user.email = params[:email]
            @user.name = params[:name]
            @user.password = params[:password]
            @user.blurb = params[:blurb]
            db = UserRepository.new(Riak::Client.new)
            if db.save(@user)
                render json: @user, status: :created, location: @user
            else
                render json: "error", status: :unprocessable_entity
            end
        end

        def show
            db = UserRepository.new(Riak::Client.new)
            @user = db.find(params[:id])
            render json: @user
        end


  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if @user.update(user_params(params[:user]))
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    head :no_content
  end

  def validate_user
    @email = User.where(email: params[:email]).exists?(conditions = :none)
    if(@email)
      @password = User.where(email: params[:email], password: params[:password]).exists?(conditions = :none)
      if(@password)
        @user = User.find_by(email: params[:email], password: params[:password])
        render "show"
      else
        render "validation failed"
      end
    else
      render "validation failed"
    end
  end

  # GET /users/splatts-fed/1
  def splatts_feed
    @feed = Splatt.find_by_sql("SELECT splatts.body, splatts.user_id, splatts.created_at FROM splatts JOIN follows ON follows.followed_id=splatts.user_id WHERE follows.follower_id = #{(params[:id])} ORDER BY created_at DESC")
    render json: @feed
  end

  def add_follows
    @user = User.find(params[:id])
    @followed = User.find(params[:follows_id])

    if @user.follows << @followed
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def delete_follows
    @user = User.find(params[:id])
    @follows = User.find(params[:follows_id])

    if @user.follows.delete(@follows)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def show_follows
    @user = User.find(params[:id])
    render json: @user.follows
  end

  def show_followers
    @user = User.find(params[:id])
    render json: @user.followed_by
  end

  def splatts
    @user = User.find(params[:id])
    render json: @user.splatts
  end

  private
    def user_params(params)
    params.permit(:email, :password, :name, :blurb)
  end

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
