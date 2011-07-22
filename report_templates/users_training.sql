-- User Trainings

select CONCAT(users.first_name, ' ', users.last_name) as 'name',
       locations.name as 'location',
       training_programs.name as 'training_type',
       training_records.expiring_on as 'certification_expiration',
       DATEDIFF(CURDATE(), DATE(training_records.expiring_on)) as 'days_until_due'
from users
inner join locations on users.location_id = locations.id
inner join training_records on users.id = training_records.user_id
inner join training_programs on training_records.training_program_id = training_programs.id
