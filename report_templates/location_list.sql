-- Locations List

select locations.name as 'Location Name',
       if(locations.store_enabled=1,'Active','Inactive') as 'Active?',
       address_geocodes.formatted_address as 'Address',
       -- No counties in db
       users.office_phone as 'Phone Number',
       users.fax as 'Fax Number',
       users.email as 'Contact Email',


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


"Location Name",
"Status",
"Address",
"Phone Number",
"Fax Number",
"Contact Email",
"Notes",
"Medical Director's Name",
"AED Coordinator's Name",
"Local EMS Name",
"Local EMS Phone Number"
