class SettingsController < ApplicationController
  def show
  end

  def toggle_gratitude
    current_user.update!(gratitude_enabled: !current_user.gratitude_enabled)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_path }
    end
  end
end
