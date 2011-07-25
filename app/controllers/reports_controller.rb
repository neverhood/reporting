class ReportsController < ApplicationController

  before_filter :valid_report_type, :only => :customize
  before_filter :valid_params, :only => :create

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  def index
    @report = Report.new
    @report_types = Report::TYPES.keys
  end

  def customize
    @report_engine = Report::TYPES[@report.type.to_sym]
  end

  def create
    @report_engine = Report::TYPES[params[:report][:type].to_sym]
    @objects = @report_engine.select(@fields_to_select).
        from(@report_engine.view).order(@order).
        limit(50).all

    respond_to do |format|
      format.js { render :json => {:table => render_to_string('reports/_report.erb'), :params => params} }
    end

  end

  private

  def valid_report_type
    @report = Report.new params[:report]
    render(guilty_response) unless Report::TYPES.include? @report.type.to_sym
  end

  def valid_params   # What, am I too pedantic?
    fields = params[:report][:fields].reject {|key,value| value.to_i != 1}.keys.map(&:to_sym)
    order = params[:report][:order_by] + ' ' + params[:report][:order_type]
    report = Report::TYPES[params[:report][:type].to_sym]
    if fields.length > 0 && ((report.fields - fields).size == (report.fields.size - fields.size)) # Smart, eh?
      @report_engine = report
      @fields_to_select = fields.join(',')
      @order = order
    else
      render guilty_response
    end
  end

end
