class Report < ActiveRecord::Base

  # We have no table for it. This is just to not leave the Rails track.
  # Actually it might be not a bad idea to create a table for that

  attr_accessor_with_default(:type, :none)
  attr_accessible :type
  attr_accessor :order_by, :order_type

  TYPES = {
      :aed => Aed,
      :location_list => LocationList,
      :maintenance_history => MaintenanceHistory,
      :user_training => UserTraining
  }

  def self.columns
    @columns ||= []
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  # Just to stay on a safe side

  def save(validate = true)
    validate ? valid? : true
  end

end
