class ShouldsController < ApplicationController
  before_action :set_should, only: %i[update destroy complete restore]

  def index
    @shoulds = current_user.shoulds.active
    @done_count = current_user.shoulds.done.count
  end

  def completed
    @shoulds = current_user.shoulds.done
  end

  def create
    @should = current_user.shoulds.new(should_params)
    if @should.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to shoulds_path }
      end
    else
      redirect_to shoulds_path
    end
  end

  def update
    if @should.update(should_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to shoulds_path }
      end
    else
      redirect_to shoulds_path
    end
  end

  def destroy
    @should.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to shoulds_path }
    end
  end

  def complete
    @should.complete!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to shoulds_path }
    end
  end

  def restore
    @should.restore!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to completed_shoulds_path }
    end
  end

  private

  def set_should
    @should = current_user.shoulds.find(params[:id])
  end

  def should_params
    params.require(:should).permit(:title)
  end
end
