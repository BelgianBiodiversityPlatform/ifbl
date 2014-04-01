class PagesController < ApplicationController
  def search
    @counters = Counter.order('name')
    
    @species = Species.find(:all, :order => 'scientific_name')
  end
end
