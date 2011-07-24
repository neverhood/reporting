class LocationList < ActiveRecord::Base

  # since we didn't want to create views right in the database we had to invent some conventions :)
  # The idea is to manipulate the self::View query as it was a table( Please check lib/AbstractTable )
  # The actual conventions are:
  #  * Aliases for each field ( underscored, to make it look native )
  #  * Alias for the entire query and set_table_name ( should be the same as set_table_name value )
  #  * SQL string must be assigned to VIEW constant
  #  * Please include AbstractTable in the end
  #  * set_primary_key is needed for the ORDER BY purposes

  set_table_name(:location_list_view)
  set_primary_key(:location_name)
  
  def self.set_field_types_and_defaults
    # aka Migration. field => type or field => [type, default_value]
    {
        :location_name => [:string],
        :active => :boolean,
        :address => :string,
        :phone_number => [:string, '911'],
        :fax_number => [:string, '123FAX4566'],
        :contact_email => :string,
        :medical_director_name => [:string, 'Bob Junior Diamond'],
        :local_ems_name => [:string, 'Ems generic'],
        :local_ems_phone_number => [:string, '44332211'],
    }
  end

  VIEW =
      <<EOF
-- LOCATIONS

-- Fields:
-- Location Name,Status,Address,Phone Number,Fax Number,Contact Email,Notes,Medical Directors Name,AED Coordinators Name,Local EMS Name,Local EMS Phone Number


(select l1.name as 'location_name',
if(l1.store_enabled=1, true, false) as 'active',
CONCAT(a1.line_one, ' ', a1.city, ' ' ,a1.state, a1.zip_code) as 'address',
u1.office_phone as 'phone_number',
u1.fax as 'fax_number',
u1.email as 'contact_email',
CONCAT(doctors.first_name, doctors.last_name) as 'medical_director_name',
ef1.form_name as "local_ems_name",
ef1.fax as "local_ems_phone_number"
from locations l1 
LEFT JOIN addresses a1 on (l1.address_id = a1.id)
LEFT JOIN organizations o1 on (l1.address_id = o1.address_id)
LEFT JOIN users u1 on ( u1.id = o1.default_contact_id )
LEFT JOIN physicians doctors on a1.id = doctors.address_id
LEFT JOIN location_ems le1 on (l1.id = le1.location_id)
LEFT JOIN ems_forms ef1 on (le1.ems_form_id = ef1.id)) AS location_list_view

EOF

  def active
    attributes.to_options[:active] == 0 ? false : true
  end

  include AbstractTable

end
