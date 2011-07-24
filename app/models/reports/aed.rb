class Aed < ActiveRecord::Base

  # since we didn't want to create views right in the database we had to invent some conventions :)
  # The idea is to manipulate the self::View query as it was a table( Please check lib/AbstractTable )
  # The actual conventions are:
  #  * Aliases for each field ( underscored, to make it look native )
  #  * Alias for the entire query and set_table_name ( should be the same as set_table_name value )
  #  * SQL string must be assigned to VIEW constant
  #  * Please include AbstractTable in the end
  #  * set_primary_key is needed for the ORDER BY purposes

  set_table_name(:aed_report_view)
  set_primary_key(:aed_serial_number)
  #set_field_types_and_defaults
  def self.set_field_types_and_defaults
    # aka Migration. field => type or field => [type, default_value]
    {
        :aed_model => [:string, 'Chinese Tentacle Reanimator'],
        :aed_serial_number => :string,
        :location_of_equipment => :string,
        :coordinator => [:string, 'God'],
        :adult_electrode_pads => :date,
        :pediatric_electrode_pads => :date,
        :aed_battery => :date,
        :adult_electrode_pads_1 => :date,
        :aed_battery_1 => :date
    }
  end

  VIEW =
      <<EOF
-- AED

-- Fields:
-- AED Model,AED Serial Number,Location of Equipment,Placement in/around Location,AED Coordinator,Adult Electrode Pads,Pediatric Electrode Pads,AED Battery,Adult Electrode Pads 1,AED Battery 1

(select CONCAT(manufacturers.name,'(', device_models.model_number, ')') as 'aed_model',
       devices.serial_number as 'aed_serial_number',
       locations.name as 'location_of_equipment',
       devices.placement as 'placement_in_or_around_location',
       CONCAT(users.first_name, users.last_name) as 'coordinator', -- No constraints here, beware of NULL
       devices.primary_electrode_pads_expiration_date as 'adult_electrode_pads',
       devices.pediatric_electrode_pads_expiration_date as 'pediatric_electrode_pads', -- mostly NULL's here, children just don't get enough love this days you know
       devices.main_battery_expiration_date as 'aed_battery',
       devices.secondary_electrode_pads_expiration_date as 'adult_electrode_pads_1',
       devices.secondary_battery_expiration_date as 'aed_battery_1'
       -- WHAT?? No "secondary pediatric electrode pads"???? Stop hating children so much!
from devices
inner join device_models on devices.device_model_id = device_models.id
inner join manufacturers on device_models.manufacturer_id = manufacturers.id -- Aed Model
inner join locations on devices.location_id = locations.id -- Location of Equipment
left outer join users on locations.user_id = users.id -- AED Coordinator, no constraints here, beware of NULL's
) as aed_report_view
EOF

  include AbstractTable

end