module ReportsHelper

  # Filters

  def filters_for field

  end

  private

  def filters_for_all
    [:is_null, :is_not_null]
  end

  def filters_for_string
    filters_for_all + [:equals, :starts_with, :ends_with, :contains]
  end

end
