# encoding: UTF-8
=begin

  Pour afficher une citations au hasard

=end

nombre_citations = site.db.table('site_cold', 'citations').count
citation_id = rand(nombre_citations)
citation_id = 1 if citation_id < 1 || citation_id > nombre_citations

redirect_to "citation/#{citation_id}/show"
