#+------------------------------------------+--------------+------+-----+---------+----------------+
#| Field                                    | Type         | Null | Key | Default | Extra          |
#+------------------------------------------+--------------+------+-----+---------+----------------+
#| id                                       | int(11)      | NO   | PRI | NULL    | auto_increment |
#| device_model_id                          | int(11)      | YES  |     | NULL    |                |
#| location_id                              | int(11)      | YES  | MUL | NULL    |                |
#| serial_number                            | varchar(255) | YES  | MUL | NULL    |                |
#| placement                                | varchar(255) | YES  |     | NULL    |                |
#| installation_date                        | date         | YES  |     | NULL    |                |
#| readiness_check_expiration_date          | date         | YES  |     | NULL    |                |
#| main_battery_expiration_date             | date         | YES  |     | NULL    |                |
#| secondary_battery_expiration_date        | date         | YES  |     | NULL    |                |
#| primary_electrode_pads_expiration_date   | date         | YES  |     | NULL    |                |
#| secondary_electrode_pads_expiration_date | date         | YES  |     | NULL    |                |
#| pediatric_electrode_pads_expiration_date | date         | YES  |     | NULL    |                |
#| earliest_expiration_date                 | date         | YES  | MUL | NULL    |                |
#| has_secondary_battery                    | tinyint(1)   | YES  |     | NULL    |                |
#| has_secondary_electrode_pads             | tinyint(1)   | YES  |     | NULL    |                |
#| has_pediatric_electrode_pads             | tinyint(1)   | YES  |     | NULL    |                |
#| other                                    | varchar(255) | YES  |     | NULL    |                |
#| physician_id                             | int(11)      | YES  | MUL | NULL    |                |
#| ems_attachment                           | varchar(255) | YES  |     | NULL    |                |
#| created_at                               | datetime     | YES  |     | NULL    |                |
#| updated_at                               | datetime     | YES  |     | NULL    |                |
#| program_type                             | int(11)      | YES  |     | NULL    |                |
#| renewed_on                               | date         | YES  |     | NULL    |                |
#| program_expiration_date                  | date         | YES  |     | NULL    |                |
#+------------------------------------------+--------------+------+-----+---------+----------------+


class Device < ActiveRecord::Base

  set_table_name :devices
  
  #ruby-1.9.2-p180 :007 > Device.first.location.name
  # => "Fitness 19 - CA 130" 
  belongs_to :location

  # TODO: Cleanup redundant

#  def self.getAll
#    find_by_sql("select d.device_model_id, l.name, d.serial_number, d.placement, d.installation_date
#                 from devices d, locations l
#                 where d.location_id = l.id")
#  end
end
