class HelmsController < ApplicationController

    def index
        @jobs = Helm.select(:jobname).distinct(:jobname).order(:jobname).map{|j| j.jobname}
        @data = Hash.new
        @jobs.each do |job|
            @data[job] = Helm.where(jobname: job).order(:created_at).map{|j| j.count_ }
        end
        # how much in the flow
        @flow = Flow.group(:flowname).count

    end
end
