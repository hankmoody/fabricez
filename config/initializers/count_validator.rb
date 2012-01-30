# config/initializers/email_validator.rb
class CountValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    if (value && !value.empty?)
      unless value =~ /^[\d]*\/?[\d]+s*\s*x\s*[\d]*\/?[\d]+s*\s*$/i
        record.errors.add(attr_name, :count, options.merge(:value => value))
      end
    end
  end
end

# This allows us to assign the validator in the model
module ActiveModel::Validations::HelperMethods
  def validates_count(*attr_names)
    validates_with CountValidator, _merge_attributes(attr_names)
  end
end