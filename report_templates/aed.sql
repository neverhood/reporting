-- AED

-- Fields:
-- AED Model,AED Serial Number,Location of Equipment,Placement in/around Location,AED Coordinator,Adult Electrode Pads,Pediatric Electrode Pads,AED Battery,Adult Electrode Pads 1,AED Battery 1

select CONCAT(manufacturers.name,'(', device_models.model_number, ')') as 'aed_model',
       devices.serial_number as 'aed_serial_number',
       locations.name as 'location_of_equipment',
       devices.placement as 'placement_in_or_around_location',
       CONCAT(users.first_name, users.last_name) as 'coordinator', -- No constraints here, beware of NULL's
       devices.primary_electrode_pads_expiration_date as 'adult_electrode_pads',
       devices.pediatric_electrode_pads_expiration_date as 'pediatric_electrode_pads', -- mostly NULL's here, children just don't get enough love this days you know
       devices.main_battery_expiration_date as 'aed_battery',
       devices.secondary_electrode_pads_expiration_date as 'adult_electrode_pads',
       devices.secondary_battery_expiration_date as 'aed_battery_1'
       -- WHAT?? No "secondary pediatric elecrode pads"???? Stop hating children so much!
from devices
inner join device_models on devices.device_model_id = device_models.id
inner join manufacturers on device_models.manufacturer_id = manufacturers.id -- Aed Model 
inner join locations on devices.location_id = locations.id -- Location of Equipment
left outer join users on locations.user_id = users.id -- AED Coordinator, no costraints here, beware of NULL's

