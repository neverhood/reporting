-- Locations List

select locations.name as 'Location Name',
       if(locations.store_enabled=1,'Active','Inactive') as 'Active?',
       address_geocodes.formatted_address as 'Address',
       -- No counties in db
       users.office_phone as 'Phone Number',
       users.fax as 'Fax Number',
       users.email as 'Contact Email',
       
