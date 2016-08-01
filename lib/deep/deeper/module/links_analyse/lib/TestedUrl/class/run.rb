# encoding: UTF-8
class TestedPage
  class << self

    # = main =
    #
    # Méthode principale appelée pour lancer l'analyse
    #
    def run

      if !defined?(ROUTE_START) || ROUTE_START.nil?
        @routes = ['site/home']
      else
        @routes = [ROUTE_START]
      end

      # On instancie la toute première TestedPage pour qu'elle
      # existe (dès qu'on trouve une route/href dans une page,
      # on instancie une TestedPage pour elle)
      hroute  = TestedPage.new(@routes.first)
      hroute.call_count = 1
      hroute.call_texts = [nil]
      hroute.call_froms = [nil]

      # Index de la route testée, utile lorsque l'on indique une
      # limite de traitement.
      iroute_tested = 0

      # On boucle sur les routes tant qu'il y en a.
      while route = @routes.shift
        begin
          # Pour les essais, on interromp au bout d'un certain nombre de
          # routes testées
          iroute_max?( iroute_tested ) ? break : iroute_tested += 1

          # === TEST DE LA ROUTE ===
          if test_route route, iroute_tested
            # OK
          else
            break
          end

        rescue Exception => e
          debug e
          say "# ERREUR FATALE EN TESTANT LA ROUTE #{route.inspect} : #{e.message}"
        end
      end
      # / Fin du while tant qu'il y a des routes
    end
    # / Fin de .run

    # Teste complet de la route +route+
    #
    # Retourne TRUE pour continuer de tester les routes, ou retourne
    # FALSE pour interrompre.
    #
    def test_route route, iroute_tested

      # La route complète, telle qu'enregistrée dans la liste
      # de toutes les routes à prendre
      # url = File.join(base_url, route)

      # On récupère l'instance de la TestedPage qui va
      # être traitée à présent
      testedpage = TestedPage[route]


      if VERBOSE
        say "* #{iroute_tested} * Test de la route #{route}"
      else
        # say (testedpage.valide? ? '*' : 'F') + " #{iroute_tested}"
        color = testedpage.valide? ? '32' : '31'
        print "\e[1;#{color}m*\e[0m"
      end

      # On regarde si cette page est valide, si elle correspond
      # à ce qu'on attend d'elle.
      testedpage.valide? || begin
        # Quand la page n'est pas valide
        testedpage.set_invalide
        # Si FAIL_FAST est true, on doit interrompre la boucle à la
        # première erreur rencontrée et afficher l'erreur.
        # Sinon, on passe à la suite.
        if FAIL_FAST
          say "#{RETRAIT}### " + testedpage.errors.join("\n#{RETRAIT}### ")
          say "#{RETRAIT}### Commande curl: #{testedpage.curl_command}"
          say "#{RETRAIT}### <a href=\"#{testedpage.url}\">#{testedpage.url}</a>" # pour y aller directement
          say "\n\nCODE DE LA PAGE :\n#{testedpage.raw_code}"
          return false
        else
          return true
        end
      end

      # Seules passent ici les pages valides.

      # On ajoute à la liste des routes les routes appelées par
      # cette page, sauf si c'est une page à l'extérieur du
      # site lui-même
      unless testedpage.hors_site?
        self.links_count += testedpage.links.count
        testedpage.links.each do |link|
          # On ne prend pas les routes javascript
          next if link.javascript?

          # Une route appelée dans la page. Elle peut avoir déjà
          # été traitée ou non.
          new_route = link.href

          if SHOW_ROUTES_ON_TESTING
            say "Cette page appelle : #{new_route.inspect}"
          end

          # On ne prend pas les routes qu'on a déjà traitées mais on
          # ajouter une valeur de présence et on passe à la suite.
          if TestedPage.exist?(new_route)

            # === UNE ROUTE CONNU ===
            TestedPage[new_route].call_count += 1
            TestedPage[new_route].call_texts << link.text
            TestedPage[new_route].call_froms << testedpage.route

          else

            # === UNE ROUTE/HREF INCONNUE ===
            # Si c, il faut créer une rangée dans hroutes et
            # ajouter la route aux routes à tester
            new_tpage = TestedPage.new(new_route)
            new_tpage.call_count = 1
            new_tpage.call_texts << link.text
            new_tpage.call_froms << testedpage.route
            @routes << new_route
          end

        end
        #/ Fin de boucle sur chaque lien trouvé dans la page
        #  courante testée

      end
      #/ Fin de si c'est une url hors de la base courante

      return true
    end
    #/ Fin de la méthode de test de la route .test_route

    # Retourne TRUE si un nombre de routes à tester maximum a été
    # décidé et qu'il est atteint.
    #
    # Rappel : Le nombre se définit dans le fichier app.rb, comme
    # tout ce qui concerne l'application en propre.
    def iroute_max? ir
      !!(NOMBRE_MAX_ROUTES_TESTED && ir > NOMBRE_MAX_ROUTES_TESTED)
    end


  end #/<< self
end #/TestedPage
