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

tag_struct.each do |key, value_arr|
  tag_type = key.to_s
  existing_tag_arr = Tag.get_names(tag_type)
  value_arr.each do |val|
    if existing_tag_arr.include?(val)
      puts "#{val} found in db, skipping.\n"
    else
      t = Tag.new(type: tag_type, tag_name: val)
      ret = t.save!
      puts "New record #{tag_type}:#{val} added.\n"
    end
  end
end

