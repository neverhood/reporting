require "csv"

class ReportsController < ApplicationController

  before_filter :valid_report_type, :only => :customize
  before_filter :valid_params, :only => :create
  before_filter :pagination, :only => :create

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  ITEMS_PER_PAGE = 24


  def index
    @report = Report.new
    @report_types = Report::TYPES.keys
  end

  def customize
    @report_engine = Report::TYPES[@report.type.to_sym]
    @objects = @report_engine.limit(10).all
    @page, @last_page, @amount = 1, 1, 10
  end

  def create
    @objects = @report_engine.
        select(@fields).
        from(@report_engine.view).
        where(@filters).
        order(@order)

    @objects = request.xhr?? @objects.limit(ITEMS_PER_PAGE).offset(@offset).all : @objects.all

    respond_to do |format|
      format.js { render :json => {:table => render_to_string('reports/_report.erb'), :params => params} }
      format.html { send_data to_csv(@objects), :type => 'text/csv',
                              :filename => "#{params[:report][:type]}_report_#{Time.now.strftime("%d%m%Y")}.csv",
                              :disposition => 'attachment' }
    end

  end

  def update

  end

  private

  def valid_report_type
    @report = Report.new :type => params[:report]
    render(guilty_response) unless Report::TYPES.include? @report.type.to_sym
  end

  def valid_params   # What, am I too pedantic?
    @fields = params[:report][:fields]
    @order = params[:report][:order_by] + ' ' + params[:report][:order_type]
    @report_engine = Report::TYPES[params[:report][:type].to_sym]
    @filters = parse_filters(@report_engine, params[:report][:filters]) if params[:report][:filters]
  end

  def pagination
    @page = (params[:report][:page] ||= 1).to_i
    @offset = (@page - 1) * ITEMS_PER_PAGE
    @amount = @report_engine.
        select(@fields).
        from(@report_engine.view).
        where(@filters).
        count
    @last_page = @amount/ITEMS_PER_PAGE + 1
  end

  def to_csv(objects)
    if objects && objects.any?
      objects.first.attrs.keys.join(',') + "\n" +            # Header
      objects.map {|object| object.attrs.values.join(',')}.join("\n")

    else
      "No data available"
    end
  end

  def parse_filters(report, filters)   # God will punish me for this one
    case_insensitive_if_string = lambda {|column|
      (report.field_types[column.to_sym] == :string)? "LOWER(#{column})" : column
    }
    stringify_if_needed = lambda do |col,op,val|
      if [:equals, :less_than, :more_than, :less_or_equal, :more_or_equal ].include? op.to_sym
        Report::DATA_MAPPING[op.to_sym].call(report.field_types[col.to_sym], val)
      else
        Report::DATA_MAPPING[op.to_sym].call(val)
      end
    end

    columns, sql_string = filters.keys, []

    columns.each do |column|
      operators_and_values = filters[column].split(';')
      if operators_and_values.size > 1
        operators = operators_and_values.map {|pair| pair.split(':')}.map(&:first)
        vals = operators_and_values.map {|pair| pair.split(':')}.map(&:last)

        operators.each do |operator|
          sql_string << ( case_insensitive_if_string.call(column) + " " +
              stringify_if_needed.call(column,operator,vals[operators.index(operator)]) )
        end

      else
        if operators_and_values.first.split(':').length > 1
          op, val = operators_and_values.first.split(':')
          sql_string << column + " " + Report::DATA_MAPPING[op.to_sym].call(report.field_types[column.to_sym],val)
        else
          sql_string << column + " " + Report::DATA_MAPPING[operators_and_values.first.to_sym] # this is 'IS NULL' or 'IS NOT NULL'
        end
      end
    end

    sql_string.join(" AND ")

  end

end


