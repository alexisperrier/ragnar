class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_title

    private
    def set_title
        @page_title = "Youtube Monitoring"
    end

end
