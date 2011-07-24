class UserTraining < ActiveRecord::Base

  # since we didn't want to create views right in the database we had to invent some conventions :)
  # The idea is to manipulate the self::View query as it was a table( Please check lib/AbstractTable )
  # The actual conventions are:
  #  * Aliases for each field ( underscored, to make it look native )
  #  * Alias for the entire query and set_table_name ( should be the same as set_table_name value )
  #  * SQL string must be assigned to VIEW constant
  #  * Please include AbstractTable in the end
  #  * set_primary_key is needed for the ORDER BY purposes

  set_table_name(:user_trainings_view)
  set_primary_key(:name)

  def self.field_types
    {
        :name => :string,
        :location => :string,
        :training_type => :string,
        :certification_expiration => :date,
        :days_until_due => :integer
    }
  end

  VIEW =
      <<EOF
-- User Trainings

(select CONCAT(users.first_name, ' ', users.last_name) as 'name',
       locations.name as 'location',
       training_programs.name as 'training_type',
       training_records.expiring_on as 'certification_expiration',
       DATEDIFF(CURDATE(), DATE(training_records.expiring_on)) as 'days_until_due'
from users
inner join locations on users.location_id = locations.id
inner join training_records on users.id = training_records.user_id
inner join training_programs on training_records.training_program_id = training_programs.id) AS user_trainings_view
EOF

  include AbstractTable

end