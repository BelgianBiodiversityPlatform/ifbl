class AjaxController < ApplicationController
  require 'csv'

  def send_contact_mail
    from = params[:sender]
    sender_name = params[:name]
    subject = params[:title]
    content = params[:content]
    for_technical_team = (params[:for_web] == 'true')
    for_scientific_team = (params[:for_scientists] == 'true')
    
    begin
      ContactMailer.contact_email(from, sender_name, subject, content, for_technical_team, for_scientific_team).deliver
      render :json => true
    rescue
      render :json => false
    end
  end

  def checklists_by_area
    a = Area.find(params[:feature_id])

    render :json => a.checklists
  end

  def checklist_by_area_csv
    a = Area.find(params[:feature_id])
    
    csv_string = CSV.generate(:col_sep => "\t", :encoding => "UTF-8") do |csv|
      csv << ['Checklist ID', 'Begin date', 'End date', 'Observers', 'IFBL area', 'Species', 'Checklist model', 'Data source']
      a.checklists.each do |checklist|
        csv << checklist.as_array_for_csv 
      end
    end

    #render :text => csv_string, :content_type => 'text/csv', :content_disposition => 'attachment; filename="checklists.csv"'
     send_data csv_string, :type => "text/plain", 
           :filename=>"entries.csv",
           :disposition => 'attachment'
  end


  def observations_per_species_and_time
    species_id = params[:species_id]
    start_date = params[:start_date] || '1000-01-01'
    end_date = params[:end_date] || '70000-12-31'
    square_name = params[:square_name]

    sql = ["SELECT * FROM observations, checklists, areas
      WHERE observations.checklist_id = checklists.id
      AND checklists.area3_id = areas.id
      AND observations.species_id=?

      AND ((checklists.begin_date, checklists.end_date) OVERLAPS (DATE ?, DATE ?))", 
      species_id.to_i, start_date, end_date]

    if square_name
      sql[0] << "AND ifbl_code LIKE '%#{square_name}%' "
    end
      
    sql[0] << "ORDER BY checklists.begin_date"
    r = Observation.find_by_sql(sql)

    if params[:format] == 'json'
      render :json => r
    elsif params[:format] == 'csv'
      csv_string = CSV.generate(:col_sep => "\t", :encoding => "UTF-8") do |csv|
	csv << ['Species ID','Zone', 'Start date', 'End Date', 'Observers']
	r.each do |res|
	  csv << [res.species_id, res.ifbl_code, res.begin_date, res.end_date, res.observers]
	end 
      end
      
      send_data csv_string, :type => "text/plain", 
           :filename=>"entries.csv",
           :disposition => 'attachment'
    end
  end
end
