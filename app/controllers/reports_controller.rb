class ReportsController < ApplicationController

  before_filter :valid_report_type, :only => :customize

  def index
    @report = Report.new
    @report_types = Report::TYPES.keys.sort
  end

  def customize
    @report_engine = Report::TYPES[@report.type.to_sym]
  end

  private

  def valid_report_type
    @report = Report.new params[:report]
    render(guilty_response) unless Report::TYPES.include? @report.type.to_sym
  end

end
