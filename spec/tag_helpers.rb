
module TagSpecHelpers

  def validate_fabric_tags (fabric, type, names_to_validate)
    scoped_tags = fabric.send(type.underscore.pluralize)
    name_list_to_validate = array_from_comma_delimited(names_to_validate)
    name_list_to_validate.each { |v| expect(scoped_tags.where(name: v)).to exist }
    expect(scoped_tags.count).to eql(name_list_to_validate.count)
  end

  def array_from_comma_delimited (str)
    str.split(',').map { |s| s.strip }
  end

  class TestTagsMaker

    def make_tags_and_associate(code, fabric = nil)
      tags_hash = parse_tag_code(code)
      tags = make_tags(tags_hash)
      associate_fabric(tags, fabric)
    end

  private

    def make_tags (tags_hash)
      tags = Array.new
      tags_hash.each do |type, name_list|
        tags = tags | name_list.map {|n| Tag.find_or_create_by!(type: type, name: n) }
      end
      tags
    end

    def associate_fabric(tags, fabric)
      tags.each {|t| t.fabrics << fabric } unless fabric.nil?
    end

    def parse_tag_code (code)
      hash = Hash.new
      code.split('_').each { |t| hash = hash.merge(get_tag_set(t)) }
      hash
    end

    def get_tag_set(code)
      tag_set = Hash.new
      split = code.split('-')
      raise 'Not enough parameters in #{code}' if split.size < 2
      type = get_type(split.shift)
      tag_set[type] = split.map { |t| get_name(t) }
      tag_set
    end

    def get_type(type_code)
      case type_code
      when 'p' 
        'Pattern'
      when 'b' 
        'BestFor'
      when 'w'
        'Weave'
      when 's'
        'Season'
      when 'o'
        'Other'
      when 'c'
        'Content'
      else
        raise 'Unknown type code #{type_code}'
      end
    end

    def get_name(name_code)
      case name_code
      when 'c'
        'Checks'
      when 's'
        'Stripes'
      when 'v'
        'Voile'
      when '100c'
        '100% Cotton'
      when 'm'
        'Menswear'
      when 'w'
        'Womenswear'
      when 'd'
        'Dobby'
      when 'sesu'
        'SeerSucker' 
      when 'blah'
        'Blah'
      else
        raise "Unknown name code #{name_code}"
      end      
    end
  end
end