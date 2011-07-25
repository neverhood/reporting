module ReportsHelper

  # Filters

  def report_fields_for(report)
    options_for_select(report.fields.map { |field| [field, {:class => report.field_types[field]}] })
  end

  def filters_for field_type
    filters = case field_type
                when :string then filters_for_string
                when :integer then filters_for_integer
                when :boolean then filters_for_boolean
                when :date then filters_for_date
              end
    "<select class='#{field_type}-filters filters'>" << options_for_select(filters.map {|filter| [filter,filter] }) << "</select>"
  end

  private

  def filters_for_all
    [:is_null, :is_not_null]
  end

  def filters_for_string
    filters_for_all + [:equals, :starts_with, :ends_with, :contains]
  end

  def filters_for_integer
    filters_for_all + [:equals, :less_than, :more_than]
  end

  def filters_for_boolean
    filters_for_all + [:true, :false]
  end

  def filters_for_date
    filters_for_all + [:equals, :less_than, :more_than]
  end

end
