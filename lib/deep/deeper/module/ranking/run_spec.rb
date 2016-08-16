feature "Page ranking" do
  before(:all) do
    Dir["./lib/deep/deeper/module/ranking/lib/**/*.rb"].each{|m| require m}
    @rank = Ranking.new('Scénario')
  end

  keywords = [
    'écrire un scénario',
    'écrire un roman',
    'boite à outils de l\'auteur',
    'analyse de film',
    'dramaturgie',
    'règle d\'écriture'

  ]
  keywords.each do |keyword|

    scenario "Recherche jusqu’à la page 20 du mot “#{keyword}”" do

      test "Recherche site sur 20 premières pages de #{keyword}"

      @rank = Ranking.new(keyword)
      kw = CGI.escape(keyword)

      visit "http://google.fr/search?q=#{kw}"
      if page.has_content?('À propos de cette page')
        sleep 30
      end
      index_page = 0

      begin
        # Début de boucle sur les 20 premières pages
        while true
          index_page += 1
          if index_page > 20
            # On peut s'arrêter ici
            break
          elsif index_page > 1
            # expect(page).to have_content "Page #{index_page}"
          else
            expect(page).to have_content 'Google'
          end
          pause = 10 + (rand(200).to_f / 10)
          sleep pause
          gpage = Ranking::GooglePage.new(@rank, index_page, page)
          gpage.analyze
          # Si le domaine courant a été trouvé, on arrête, sinon,
          # on continue
          if gpage.domain_found?
            puts "\n\nSITE TROUVÉ À LA PAGE #{index_page} !"
            break
          end
          has_bouton_suivant = false
          within('div#foot[role="navigation"]'){has_bouton_suivant = page.has_link?('Suivant')}
          if has_bouton_suivant
            within('div#foot[role="navigation"]'){click_link "Suivant"}
          else
            has_lien_all_resultats =
              within('div#extrares'){page.has_link?('relancer la recherche pour inclure les résultats omis')}
            if has_lien_all_resultats
              within('div#extrares') do
                click_link 'relancer la recherche pour inclure les résultats omis'
                @rank.reset_resultats
                index_page = 0
              end
            else
              puts "\n\nSITE NON TROUVÉ JUSQU'À LA DERNIÈRE PAGE #{index_page}"
              break
            end
          end

          # break # pour tester seulement une page

        end
        # /boucle itime
      rescue Exception => e
        puts "# ERREUR : #{e.message}\n" + e.backtrace.join("\n")
      ensure
        puts @rank.result
        puts @rank.report
      end
    end
    # /test
  end
  # / Boucle sur chaque mot-clé

  # Scénario
end
