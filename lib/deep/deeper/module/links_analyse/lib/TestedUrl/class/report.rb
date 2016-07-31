# encoding: UTF-8
=begin

=end
class TestedUrl
  class << self

    # = main =
    #
    # Établissement du rapport d'analyse des liens
    #
    def report

      say "\n\n\n"
      say "="*80
      say "= ANALYSE DES LIENS DU #{Time.now}"
      say "="*80
      say "\n\n"
      say "= NOMBRE DE ROUTES TESTÉES : #{hroutes.count}"
      say "= NOMBRE PAGES INVALIDES   : #{invalides.count}"
      say "= NOMBRE PAGES VALIDES     : #{hroutes.count - invalides.count}"
      say "\n\n"

      routes_sorted = hroutes.sort_by{|k,v| v[:call_count]}
      plus_visited  = routes_sorted.values.first
      moins_visited = routes_sorted.values.last
      say "= Route la plus visitée    : #{plus_visited[:route]}"
      say "= Route la moins visitée   : #{moins_visited[:route]}"

      say "\n\n"

    end


    def rieen

    end

  end #/ << self
end #/TestedUrl
