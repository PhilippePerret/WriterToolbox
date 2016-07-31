# encoding: UTF-8
class TestedUrl
  class << self

    # = main =
    #
    # Méthode principale appelée pour lancer l'analyse
    #
    def run

      @routes = ['site/home']
      @hroutes = {
        'site/home' => {
          call_count: 10,
          call_texts: [nil],
          call_froms: [nil],
          testedurl:   nil
        }
      }

      iroute_tested = 0

      while route = @routes.pop

        # Pour les essais, on interromp au bout d'un certain nombre de
        # routes testées
        if NOMBRE_MAX_ROUTES_TESTED && iroute_tested > NOMBRE_MAX_ROUTES_TESTED
          break
        else
          iroute_tested += 1
        end
        # La route complète, telle qu'enregistrée dans la liste
        # de toutes les routes à prendre
        # url = File.join(base_url, route)

        say "*** Test de la route #{route}"

        testedurl = TestedUrl.new(route)

        testedurl.valide? || begin
          # Quand la page n'est pas valide
          #
          TestedUrl.add_invalide testedurl
          retrait = '    '
          say "#{retrait}# INVALIDE"
          if FAIL_FAST
            # On doit interrompre la boucle à la première erreur
            # rencontrée et afficher l'erreur
            say "#{retrait}### " + testedurl.errors.join("#{retrait}### ")
            break
          end
          next
        end

        # On ajoute à la liste des routes les routes appelées par
        # cette page, sauf si c'est une page à l'extérieur du
        # site lui-même
        unless testedurl.hors_site?
          testedurl.links.each do |link|
            # On ne prend pas les routes javascript
            next if link.javascript?
            # On ne prend pas les routes qu'on a déjà traitées mais on
            # ajouter une valeur de présence
            if @hroutes.key?(link.href)
              @hroutes[link.href][:call_count] += 1
              @hroutes[link.href][:call_texts] << link.text
              @hroutes[link.href][:call_froms] << testedurl.id
              next
            else
              # Sinon, il faut créer une rangée dans hroutes et
              # ajouter la route aux routes à tester
              @hroutes.merge!(
                link.href => {
                  call_count: 1,
                  call_texts: [link.text],
                  call_froms: [testedurl.id],
                  testedurl:  testedurl.id
                }
              )
              @routes << link.href
            end
            # debug "TEXT : #{link.text}"
            # debug "HREF : #{link.href}"

          end #/ fin de boucle sur chaque lien trouvé
        end #/Fin de si c'est une url hors de la base courante


        # On prend la donnée hroutes après avoir renseigné son
        # instance TestedUrl
        @hroutes[route][:testedurl] = testedurl.id

      end #/Fin de la boucle sur toutes les routes
    end

  end #/<< self
end #/TestedUrl
