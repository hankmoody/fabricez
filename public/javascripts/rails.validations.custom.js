// public/javascripts/rails.validations.custom.js

// The validator variable is a JSON Object
// The selector variable is a jQuery Object
clientSideValidations.validators.local['count'] = function(element, options) {
  // Your validator code goes in here
  if (element.val().length > 0) {
	  if (!/^[\d]*\/?[\d]+s*\s*x\s*[\d]*\/?[\d]+s*\s*$/i.test(element.val())) {
	    // When the value fails to pass validation you need to return the error message.
	    // It can be derived from validator.message
	    return options.message;
	  }
  }
}