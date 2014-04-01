# To change this template, choose Tools | Templates
# and open the template in the editor.

class Viewer < ActiveRecord::Base
  # We can't name the model Observer (Rails has an Observer class)
  set_table_name 'observers'

  belongs_to :checklist
  belongs_to :person
end
