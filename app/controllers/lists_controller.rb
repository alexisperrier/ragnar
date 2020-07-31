class ListsController < ApplicationController
    before_action :set_list, only: [:show, :edit, :update]

    def index
    end

    def show
    end

    def edit
    end

    def update
    end

    def new
    end

    def destroy
    end

    # ----------------------------------------------------------------------
    # Private
    # ----------------------------------------------------------------------
    private
    def set_list
        @list = List.includes(:user).find(params[:id])
        @page_title = "YT List #{@list.title}"
    end


end
