require "csv"

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
    @page = (params[:report][:page] ||= 1).to_i
    items_per_page = 24
    offset = (@page - 1) * items_per_page
    @report_engine = Report::TYPES[params[:report][:type].to_sym]
    @objects = @report_engine.select(@fields_to_select).
        from(@report_engine.view).order(@order).
        limit(items_per_page).offset(offset).all
    @amount = @report_engine.select(@fields_to_select).
        from(@report_engine.view).order(@order).count # awesome :)
    @last_page = @amount/items_per_page + 1

    Rails.logger.debug "#{@fields_to_select} <<<<<<<<<< #{@report_engine}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

    respond_to do |format|
      format.js { render :json => {:table => render_to_string('reports/_report.erb'), :params => params} }
      format.csv {
        render :update do |page|
          csv_string = CSV.generate do |cs|
            @objects.each do |item|
              cs << []#@fields_to_select
            end
          end
          #render_csv "users-#{Time.now.strftime("%d%m%Y")}"
          page.redirect_to :action => "file_sender"
        end
      }
    end

  end

  def file_sender(csv_string=nil)
     send_data csv_string, :type => "text/csv", :filename => 'olol.csv', :disposition => 'attachment'
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

  def render_csv(filename= nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers['Content-type'] = 'text/plain'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = '0'
    else
      headers['Content-type'] = 'text/csv'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    end



  end

end