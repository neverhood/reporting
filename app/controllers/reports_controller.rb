require "csv"

class ReportsController < ApplicationController

  before_filter :valid_report_type, :only => :customize
  before_filter :valid_params, :only => :create

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  ITEMS_PER_PAGE = 24

  def index
    @report = Report.new
    @report_types = Report::TYPES.keys
  end

  def customize
    @report_engine = Report::TYPES[@report.type.to_sym]
  end

  def create
    @page = (params[:report][:page] ||= 1).to_i
    offset = (@page - 1) * ITEMS_PER_PAGE
    @report_engine = Report::TYPES[params[:report][:type].to_sym]
    @objects = @report_engine.select(@fields_to_select).
        from(@report_engine.view).where(@filters).order(@order).
        limit(ITEMS_PER_PAGE).offset(offset).all
    @amount = @report_engine.select(@fields_to_select).
        from(@report_engine.view).where(@filters).count
    @last_page = @amount/ITEMS_PER_PAGE + 1

    Rails.logger.debug "#{@fields_to_select} <<<<<<<<<< #{@report_engine}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"


    respond_to do |format|
      format.js {
        if params[:report][:csv] == "false"
          render :json => {:table => render_to_string('reports/_report.erb'), :params => params}
        else
          render :update do |page|
            csv_string = CSV.generate do |cs|
              cs << "hello this is first line".split
              @objects.each do |item|
                cs << item.attrs.values.each
              end
#              params[:objects].each do |item|
##                Rails.logger.debug "#{item[0]}"
#                  cs << [item[0], item[1] ]#@fields_to_select
#              end
            end

#          page.redirect_to :controller => :reports, :action => "file_sender", :param1 => csv_string
           page.redirect_to csv_string, :type => "text/csv", :filename => 'olol.csv', :disposition => 'attachment'
        end
        end }
    end

  end

  def file_sender()
    Rails.logger.debug "PARAMS:   #{params[:param1]} ==============="

    send_data csv_string, :type => "text/csv", :filename => 'olol.csv', :disposition => 'attachment'
    #render_csv "users-#{Time.now.strftime("%d%m%Y")}"
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
      @filters = parse_filters(@report_engine, params[:report][:filters]) if params[:report][:filters]
    else
      render guilty_response
    end
  end

  def render_csv(filename= nil)  #will test this approach
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

  def parse_filters(report, filters)   # God will punish me for this one
      string = ' '
      filters.each do |filter|
        string << ' AND ' unless string.gsub(/\s/, '').blank?
        if report.field_types[filter.first.to_sym] == :string
           string << " LOWER(#{filter.first}) "
        else
          string << filter.first
        end

        values = filter.last.split(';')
        values.each do |value|
          if value.split(':').size == 1
            string += Report::DATA_MAPPING[value.to_sym]
          else
            op, val = value.split(':')
            if [:equals, :less_than, :more_than, :less_or_equal, :more_or_equal].include?(op.to_sym)
              string += ' ' + Report::DATA_MAPPING[op.to_sym].call(report.field_types[filter.first.to_sym],val)
            else
               string += Report::DATA_MAPPING[op.to_sym].call(val)
            end
           string += " AND #{filter.first} " if (values.index(value) != values.size - 1)
          end
        end
      end
  string
  end

end

