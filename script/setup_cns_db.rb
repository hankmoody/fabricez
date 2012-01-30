#!/usr/bin/env ruby.exe

# This script will set up initial database structure

## Setup tags ##
tag_struct = {
  :pattern => ['Check', 'Stripe', 'Gingham', 'Scottish'],
  :weave => ['Plain', 'Twill', 'Herringbone', 'Jacquard', 'Seer-Sucker', 'Voile', 'Dobby'],
  :season => ['Spring-Summer', 'Autumn-Winter'],
  :material => ['Cotton', 'Rayon', 'Polyester', 'Viscose', 'Lycra'],
  :best_for => ['Men\'s Wear', 'Ladies Wear', 'Kid\'s Wear', 'Home Furnishing', 'Uniform'],
  :contents => ['100% Cotton'],
}

roles_struct = {
  "free" => 15,
  "admin" => 15,
  "premium50" => 50,
  "premium100" => 100
}

tag_struct.each do |key, value_arr|
  tag_type = key.to_s
  existing_tag_arr = Tag.get_names(tag_type).map { |t| t.downcase }
  value_arr.each do |val|
    if existing_tag_arr.include?(val.downcase)
      puts "#{val} found in db, skipping.\n"
    else
      t = Tag.new(tagtype: tag_type, name: val)
      ret = t.save!
      puts "New record #{tag_type}:#{val} added.\n"
    end
  end
end

roles_struct.each do |key, value|
  Role.create(category: key, limit: value) unless Role.where(category: key).exists?
end

