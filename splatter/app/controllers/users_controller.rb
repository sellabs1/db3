class UsersController < ApplicationController
#   applies the set_headers method before performing other methods
    before_filter :set_headers

#   GET /users
#   GET /users.json
    def index
        db = UserRepository.new(Riak::Client.new)        
        @users = db.all
        render json: @users
    end

#   POST /users
    def create
        @user = User.new
        @user.email = params[:user][:email]
        @user.name = params[:user][:name]
        @user.password = params[:user][:password]
        @user.blurb = params[:user][:blurb]
        db = UserRepository.new(Riak::Client.new)
        if db.save(@user)
            render json: @user, status: :created, location: @user
        else
            render json: "error", status: :unprocessable_entity
        end
    end

#   GET /users/1
    def show
        db = UserRepository.new(Riak::Client.new)
        @user = db.find(params[:id])
        render json: @user
    end

#   PATCH/PUT /users/1
#   PATCH/PUT /users/1.json
    def update
        db = UserRepository.new(Riak::Client.new)
        @user = db.find(params[:id])

        if db.update(user_params(params[:user]))
            render json: @user, status: :updated, location: @user
        else
            render json: "error", status: :unprocessable_entity
        end
    end

#   DELETE /users/1
#   DELETE /users/1.json
    def destroy
        db = UserRepository.new(Riak::Client.new)
        db.delete(params[:id])
        head :no_content
    end

#   Validate User Method
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

#   GET /users/splatts-feed/1
    def splatts_feed
        @id = params[:id]
        db = UserRepository.new(Riak::Client.new)
        @feed = db.splatts_feed(@id) 
        render json: @feed
    end

#   POST /users/follows
    def add_follows
        db = UserRepository.new(Riak::Client.new)
        @follower = db.find(params[:id])
        @followed = db.find(params[:follows_id]
        
	if db.follow(@follower, @followed)
	    head :no_content
	else
	    render json: "error adding follows", status: :unprocessable_entity
	end
    end

#   DELETE /users/follows/1/2
    def delete_follows
        db = UserRepository.new(Riak::Client.new)
        @user = db.find(params[:id])
        @follows = db.find(params[:follows_id])

        if db.unfollow(@user, @follows)
            head :no_content
        else
            render json: "error deleting follows", status: :unprocessable_entity
        end
    end

#   GET /users/follows/1
    def show_follows
        db = UserRepository.new(Riak::Client.new)
        @user = db.find(params[:id])
        render json: @user.follows
    end

#   GET /users/followers/1
    def show_followers
        db = UserRepository.new(Riak::Client.new)
        @user = db.find(params[:id])
        render json: @user.followers
    end

#   POST /users/splatts
    def splatts
        db = UserRepository.new(Riak::Client.new)
        @user = db.find(params[:id])
        db = SplattRepository.new(Riak::Client.new, @user)
        render json: db.all
    end

    private
        def user_params(params)
            params.permit(:email, :password, :name, :blurb)
        end

        def set_headers
            headers['Access-Control-Allow-Origin'] = '*'
        end
end
