require 'csv'

keys = ["Name", "City", "People Category", "Profile Link", "Headshot", "Comments", "Reference Links", "Submitted By", "Country", "Approved", "Uploaded", "Reviewer", "Last Modified"]

file = '../../tsv/malaysia/people.tsv'
rows = CSV.read( file , { col_sep: "\t" } ).map { |a| Hash[ keys.zip(a) ] }
category = "People"
exclude_tags = ["Name", "Submitted By", "Approved", "Comments", "Reference Links", "Country", "Uploaded", "Reviewer", "Last Modified"]
rows.each_with_index do |row,index|
  tags = ["category" => category.downcase]
  if index > 0
    name = ''
    comments = ''
    reference_links = ''
    uploaded = 'N'
    moderator_id = 1
    user_id = 1
    links = ''
    
    row.each do |tag|
      tag[1] = "" if tag[1].nil?
      tags.push Hash[tag[0] => tag[1]] unless exclude_tags.include?(tag[0])
      name = tag[1] if tag[0].eql?("Name")
      uploaded = tag[1] if tag[0].eql?("Uploaded")
      comments = tag[1] if tag[0].eql?("Comments")
      links = tag[1] if tag[0].eql?("Reference Links")
      if tag[0].eql?("Reviewer")
        moderator_id = 11 if tag[1].eql?('WSR-Bowei')
      end
      if tag[0].eql?("Submitted By")
        user_id = 11 if tag[1].eql?('WSR-Bowei')
      end

    end
    body = comments
    body = body + "\n\n Reference Links: #{links}" if links.present?
    
    Submission.create(silk_identifier: "Philippines:#{category}:#{name}", country: "Philippines", user_id: user_id, moderator_id: moderator_id, status: "imported", content: Hash["tags" => tags, "body" => body].to_json)
  end
end


