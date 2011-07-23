#+-----------------+--------------+------+-----+---------+----------------+
#| Field           | Type         | Null | Key | Default | Extra          |
#+-----------------+--------------+------+-----+---------+----------------+
#| id              | int(11)      | NO   | PRI | NULL    | auto_increment |
#| name            | varchar(255) | YES  | MUL | NULL    |                |
#| organization_id | int(11)      | YES  | MUL | NULL    |                |
#| address_id      | int(11)      | YES  |     | NULL    |                |
#| ems_form_id     | int(11)      | YES  |     | NULL    |                |
#| user_id         | int(11)      | YES  |     | NULL    |                |
#| pay_status      | int(11)      | YES  |     | NULL    |                |
#| payer           | int(11)      | YES  |     | NULL    |                |
#| pay_period      | int(11)      | YES  |     | NULL    |                |
#| invoice_method  | int(11)      | YES  |     | NULL    |                |
#| created_at      | datetime     | YES  |     | NULL    |                |
#| updated_at      | datetime     | YES  |     | NULL    |                |
#| building_name   | varchar(255) | YES  |     | NULL    |                |
#| expiration_date | date         | YES  |     | NULL    |                |
#| store_enabled   | tinyint(1)   | YES  |     | NULL    |                |
#| external_id     | int(11)      | YES  | MUL | NULL    |                |
#+-----------------+--------------+------+-----+---------+----------------+


class Location < ActiveRecord::Base
  include AbstractTable

#  attr_accessor  :location_name, :active, :address, :phone_number, :fax_number, :contact_email, :medical_director_name, 
#                 :local_ems_name, :local_ems_phone_number,
#
#  attr_accessible  :location_name, :active, :address, :phone_number, :fax_number, :contact_email, :medical_director_name, 
#                   :local_ems_name, :local_ems_phone_number,


   View =
    <<EOF
-- LOCATIONS

-- Fields:
-- Location Name,Status,Address,Phone Number,Fax Number,Contact Email,Notes,Medical Directors Name,AED Coordinators Name,Local EMS Name,Local EMS Phone Number


select l1.name as 'location_name', 
if(l1.store_enabled=1, 'Active', 'Inactive') as 'active',
CONCAT(a1.line_one, ' ', a1.city, ' ' ,a1.state, a1.zip_code) as 'address',
u1.office_phone as 'phone number',
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
LEFT JOIN ems_forms ef1 on (le1.ems_form_id = ef1.id);

EOF


end
