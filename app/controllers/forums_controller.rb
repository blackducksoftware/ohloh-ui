class ForumsController < ApplicationController
  before_action :find_forum_record, except: [:index, :new, :create]
  before_action :admin_session_required, except: [:index, :show]

  def index
    @forums = Forum.all
  end

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new(forum_params)
    respond_to do |format|
      if @forum.save 
        format.html { redirect_to forums_path, flash: { success: t('.success') } }
      else
        format.html { redirect_to forums_path, flash: { error: t('.error') } }
      end
    end
  end

  def update
    respond_to do |format|
      if @forum.update(forum_params)
        format.html { redirect_to forums_path, flash: { success: t('.success') } }
      else
        format.html { redirect_to forums_path, flash: { success: t('.error') } }
      end
    end
  end

  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
    end
  end

  private

  def find_forum_record
    @forum = Forum.find_by(id: params[:id])
  end

  def forum_params
    params.require(:forum).permit(:name, :topics_count, :posts_count, :position)
  end
end
