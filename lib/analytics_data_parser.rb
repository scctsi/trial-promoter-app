class AnalyticsDataParser
  def self.parse(data)
    # Step 1: Find the column which has the service update id
<<<<<<< HEAD
    # service_update_id_column_index = @data.columns.index('service_update_id')
    
    # # Step 2: Go through every row in the data
    # metrics = {}
    # data.rows.each do |row|
    #   BufferUpdate.where(service_update_id: row[service_update_id_column_index])
    # end
=======
    service_update_id_column_index = @data.columns.index('service_update_id')
    
    # Step 2: Go through every row in the data
    metrics = {}
    data.rows.each do |row|
      BufferUpdate.where(service_update_id: row[service_update_id_column_index])
    end
>>>>>>> remove-colon
  end
end