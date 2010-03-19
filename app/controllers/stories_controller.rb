class StoriesController < ApplicationController

  def new
      if current_user.nil?
        flash[:error] = "You must be logged in to create a story."
        redirect_to login_path
      end
  end
  
  def create
    @story = Story.new(params[:story])
    
    @story.owner = current_user
    if !@story.save
      render :action => 'new'
    else
      @story.collaborators.create({:user => current_user})
    
      if @story.save
        flash[:notice] = "You've started your story! Now it's time to add the first fic."
        redirect_to(@story)
      else
        flash[:error] = "There was a problem starting your story."
        # Rollback the initial save
        @story.destroy unless @story.new_record?
        render :action => 'new'
      end
    end
  end
  
  def show
    @story = Story.find(params[:id])
    @fics = @story.fics
  end
  
  def index
    if params[:id]
      @user = User.find(params[:id])
      @stories = @user.stories
      render :template => "stories/user_stories"
    else
      @stories = Story.find(:all, :order => "created_at DESC", :limit => 5)
      @fics = Fic.find(:all, :order	=> "created_at DESC", :limit	=> 5)
    end
  end

  def rss
    @story = Story.find(params[:id], :order => "id DESC", :limit => 10)
    @fics = @story.fics
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  
end