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
    if @forum.save
      redirect_to forums_path, flash: { success: t('.success') }
    else
      redirect_to forums_path, flash: { error: t('.error') }
    end
  end

  def update
    if @forum.update(forum_params)
      redirect_to forums_path, flash: { success: t('.success') }
    else
      redirect_to forums_path, flash: { success: t('.error') }
    end
  end

  def destroy
    @forum.destroy
    redirect_to forums_path
  end

  private

  def find_forum_record
    @forum = Forum.find_by(id: params[:id])
  end

  def forum_params
    params.require(:forum).permit(:name, :position)
  end
end
