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
end
