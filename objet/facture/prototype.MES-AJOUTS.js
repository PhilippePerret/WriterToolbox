/**
	Ajout de méthodes pratiques à prototype
**/
Element.addMethods({
	togglev: function(element) {
		element=$(element);
		Element[Element.visiblev(element) ? 'hidev' : 'showv'](element);
		return element;
	},
	visiblev: function(element) {
    	return $(element).style.visibility != 'hidden';
  	},
  	hidev: function(element) {
  		element = $(element);
  		element.style.visibility = 'hidden';
  		return element;
  	},
  	showv: function(element) {
  		element = $(element);
  		element.style.visibility = 'visible';
  		return element;
  	},
});