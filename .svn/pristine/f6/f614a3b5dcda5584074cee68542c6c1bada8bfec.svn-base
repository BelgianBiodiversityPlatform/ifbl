# To change this template, choose Tools | Templates
# and open the template in the editor.

class Checklist < ActiveRecord::Base
  belongs_to :model
  belongs_to :source 
 
  belongs_to :area1, :class_name => 'Area' # Biggest zone (32x20km ?)
  belongs_to :area2, :class_name => 'Area' # 4x4 km zone
  belongs_to :area3, :class_name => 'Area' # 1x1 km zone

  def most_precise_area
    area3 || area2 || area1
  end

  has_many :observations
  has_many :viewers



  def as_json(options={})
    {
      :id => self.id,
      :begin_date => self.begin_date,
      :end_date => self.end_date,
      :observers => self.observers,
      :concern_area => self.most_precise_area.ifbl_code,
      :species => self.observations.map{|o| [o.species.id, o.species.scientific_name]}.sort_by{|s| s[1]},
      :model => self.model.name,
      :source => self.source.name
    }
  end

  def as_array_for_csv
    [self.id,
      self.begin_date,
      self.end_date,
      self.observers,
      self.most_precise_area.ifbl_code,
      self.observations.map{|o| o.species.scientific_name}.join(' '),
      self.model.name,
      self.source.name
      ]

  end

end
