-- Maintenance History

select locations.name as 'location',
       devices.placement as 'placement',
       devices.serial_number as 'serial_number',
       device_check_records.created_at as 'inspection_date',
       device_check_records.name_checker as 'inspector_name',
       device_check_records.notes as 'issues' 
from devices 
inner join locations on devices.location_id = locations.id
inner join device_check_records on devices.id = device_check_records.device_id
