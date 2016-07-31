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

    end
  end #/ << self
end #/TestedUrl
