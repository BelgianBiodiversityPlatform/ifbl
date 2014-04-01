# To change this template, choose Tools | Templates
# and open the template in the editor.

class Area < ActiveRecord::Base
  #has_many :checklists Not valid anymore since the link is multiple...
  belongs_to :model

  named_scope :with_direct_checklists, :conditions => {:has_direct_checklists => true}

  def checklists
    case self.a_type
      #when 1 then Checklist.find(:all, :conditions => {:area3_id => self.id})
      #when 4 then Checklist.find(:all, :conditions => {:area2_id => self.id})
      #when 32 then Checklist.find(:all, :conditions => {:area1_id => self.id})
      
      when 1 then Checklist.where(:area3_id => self.id).includes({:observations => [:species]}, :model, :source, :viewers, :area2, :area3)
      when 4 then Checklist.where(:area2_id => self.id).includes({:observations => [:species]}, :model, :source, :viewers, :area2, :area3)
      when 32 then Checklist.where(:area1_id => self.id).includes({:observations => [:species]}, :model, :source, :viewers)
      else []  
    end
    
  end

  def a_type
    case coordinatesystem
      when 'IFBL 1km' then 1
      when 'IFBL 4km' then 4
      when '32x20km' then 32
    end
  end
end
