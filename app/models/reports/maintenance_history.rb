class MaintenanceHistory < ActiveRecord::Base

  VIEW =
      <<EOF
-- Maintenance History

(select locations.name as 'location',
       devices.placement as 'placement',
       devices.serial_number as 'serial_number',
       device_check_records.created_at as 'inspection_date',
       device_check_records.name_checker as 'inspector_name',
       device_check_records.notes as 'issues'
from devices
inner join locations on devices.location_id = locations.id
inner join device_check_records on devices.id = device_check_records.device_id) AS maintenance_history_view
EOF

  include AbstractTable

  # since we didn't want to create views right in the database we had to invent some conventions :)
  # The idea is to manipulate the self::View query as it was a table( Please check lib/AbstractTable )
  # The actual conventions are:
  #  * Aliases for each field ( underscored, to make it look native )
  #  * Alias for the entire query and set_table_name ( should be the same as set_table_name value )
  #  * SQL string must be assigned to VIEW constant
  #  * Please include AbstractTable in the end
  #  * set_primary_key is needed for the ORDER BY purposes

  set_table_name(:maintenance_history_view)
  set_primary_key(:serial_number)

  def self.default_columns_order
    [:location, :placement, :serial_number, :inspection_date, :inspector_name, :issues]
  end

  populate_object_with_default_values :false # true is default

  def self.set_field_types_and_defaults
    {
        :location => :string,
        :placement => :string,
        :serial_number => :string,
        :inspection_date => :date,
        :inspector_name => :string,
        :issues => [:string, 'No issues']
    }
  end

end