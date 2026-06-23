class ShouldsController < ApplicationController
  before_action :set_should, only: %i[update destroy complete restore]

  def index
    @shoulds = Should.active
    @done_count = Should.done.count
  end

  def completed
    @shoulds = Should.done
  end

  def create
    @should = Should.new(should_params)
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
    @should = Should.find(params[:id])
  end

  def should_params
    params.require(:should).permit(:title)
  end
end
