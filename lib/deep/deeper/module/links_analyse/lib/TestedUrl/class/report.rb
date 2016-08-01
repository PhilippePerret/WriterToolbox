# encoding: UTF-8
=begin

=end
class TestedPage
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
      say "= NOMBRE DE ROUTES TESTÉES : #{instances.count}"
      say "= NOMBRE PAGES INVALIDES   : #{invalides.count}"
      say "= NOMBRE PAGES VALIDES     : #{instances.count - invalides.count}"
      say "\n\n"

      pages_sorted = instances.values.sort_by{|v| v.call_count}
      plus_visited  = pages_sorted.first
      moins_visited = pages_sorted.last
      say "= Route la plus visitée    : #{plus_visited.route}"
      say "= Route la moins visitée   : #{moins_visited.route}"

      say "\n\n"

    end


    def rieen

    end

  end #/ << self
end #/TestedPage
