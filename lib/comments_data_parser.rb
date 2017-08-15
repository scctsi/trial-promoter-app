class CommentsDataParser
  def self.convert_to_parseable_data(content)
    data = OpenStruct.new
    data.column_headers = ['Date of Message', 'Message', 'Date of Comment', 'Comment', 'Commentator Username', 'Action Taken', 'Comment Type', 'Comment Syntax', 'Rationale(s) for Action/Categorization', 'Notes']
    data.rows = content[1..-1]
    data
  end

  def self.parse(data)
    # Step 1: Find the column which has the message text
    message_content_column_index = data.column_headers.index('Message')

    # Step 2: Go through every row in the data
    parsed_data = {}
    data.rows.each do |row|
      comments = {}
      message = Message.where(content: row[message_content_column_index])[0]
      next if message.nil?

      data.column_headers.each.with_index do |column_header, index|
        if !column_header.blank? && !(column_header == 'Message')
          comments[column_header] = row[index]
        end
      end
      parsed_data[message.to_param] = comments
    end

    parsed_data
  end

  def self.store(parsed_data)
    parsed_data.each do |message_param, comments|
      message = Message.find_by_param(message_param)
      message.comments << Comment.new(content: content)
      message.save
    end
  end
end