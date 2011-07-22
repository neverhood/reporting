-- Locations List

select locations.name as 'Location Name',
       if(locations.store_enabled=1,'Active','Inactive') as 'Active?',
       address_geocodes.formatted_address as 'Address',
       -- No counties in db
       users.office_phone as 'Phone Number',
       users.fax as 'Fax Number',
       users.email as 'Contact Email',


select l1.name, 
l1.store_enabled,
l1.address_id,
a1.line_one,
u1.office_phone,
u1.fax,
u1.email,
doctors.last_name,
em1.form_name as "Local EMS Name",
em1.fax as "Local EMS Phone Number"
from locations l1 
LEFT JOIN addresses a1 on (l1.address_id = a1.id)
LEFT JOIN organizations o1 on (l1.address_id = o1.address_id)
LEFT JOIN users u1 on ( u1.id = o1.default_contact_id )
LEFT JOIN physicians doctors on a1.id = doctors.address_id
LEFT JOIN location_ems le1 on (l1.id = le1.location_id)
LEFT JOIN ems_forms ef1 on (le1.ems_form_id = ef1.id) 




--from locations loc JOIN addresses adr on loc.address_id = adr.id
--JOIN organizations org on loc.address_id = org.address_id
--JOIN users usr on usr.id = org.default_contact_id
JOIN device_check_records dcr JOIN devices dev on loc.id = dev.location_id and
dcr.device_id = dev.id
JOIN physicians doctors on dev.physician_id = doctors.id
JOIN location_ems on loc.id = location_ems.location_id
JOIN ems_forms on location_ems.ems_form_id = ems_forms.id
JOIN devices devs on loc.id = devs.location_id 
JOIN users usrs on loc.user_id = usrs.id;

---
--join organizations ) join users ) join device_check_records )
---
from(
	((((locations join addresses) join organizations ) join users ) join device_check_records )
) 


--usr.office_phone as "Phone Number", 
--usr.fax as "Fax Number", 
--usr.email as "Contact Emails",
--dcr.notes as "NOTES",
--doctors.last_name as "Medical Directors Name",
--ems_forms.form_name as "Local EMS Name",
--ems_forms.fax as "Local EMS Phone Number"
       
