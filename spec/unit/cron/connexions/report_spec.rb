describe 'Rapport de connexions' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end


  # ::report
  describe 'Méthode ::generate_report' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :generate_report
    end
  end

  describe '::build_report' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :build_report
    end
  end

  describe '::save_report' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :save_report
    end
  end

  describe '::send_report' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :send_report
    end
  end

  # ---------------------------------------------------------------------
  #
  #   CONTENU DU RAPPORT
  #
  # ---------------------------------------------------------------------

  describe 'Contenu du rapport final' do
    let(:report) { @report ||= begin
      Connexions::Connexion.generate_report
      Connexions::Connexion.report # le rapport String
    end
    }

    it ' définit le nombre d’IPS différentes' do
      nombre_ips = Connexions::Connexion.select.collect{|h|h[:ip]}.uniq
      nombre_ips = nombre_ips.reject{|ip|ip == 'TEST'}.count
      expect(report).to include "<span class='libelle'>Nombre total d’IPs</span><span class='value'>#{nombre_ips}</span>"
    end

    def nombre_search_engines_and_particuliers
      @nombre_particuliers === nil && begin
        @nombre_particuliers    = 0
        ips = Connexions::Connexion.select.collect{|h|h[:ip]}.uniq
        ips = ips.reject{|ip| ip == 'TEST'}
        nombre_total_ips = ips.count
        liste_ips_traited = Hash.new
        ips.each do |ip|
          liste_ips_traited.key?(ip) && next
          liste_ips_traited.merge!(ip => true)
          sengine = Connexions::IP.get_search_engine_with_ip(ip)
          if sengine.nil?
            @nombre_particuliers += 1
          end
        end
        @nombre_search_engines = nombre_total_ips - @nombre_particuliers
      end
      [@nombre_search_engines, @nombre_particuliers]
    end

    it 'définit le nombre de moteurs de recherche' do
      nb = nombre_search_engines_and_particuliers.first
      expect(report).to include "<span class='libelle'>Nombre de moteurs de recherche</span><span class='value'>#{nb}</span>"
    end
    it 'définit le nombre de particuliers' do
      nb = nombre_search_engines_and_particuliers.last
      expect(report).to include "<span class='libelle'>Nombre de particuliers</span><span class='value'>#{nb}</span>"
    end

    it 'définit le nombre de routes' do
      nombre_routes = Connexions::Connexion.select.collect{|h|h[:route]}.uniq.count
      expect(report).to include "<span class='libelle'>Nombre de routes</span><span class='value'>#{nombre_routes}</span>"
    end

    it 'définit la durée totale de visite' do
      duree_totale = 0
      Connexions::Connexion.resultats[:per_ip].each do |ip, dip|
        duree_totale += dip.duree_connexion
      end
      expect(duree_totale).to be > 0
      duree_totale = duree_totale.as_horloge
      expect(report).to include "<span class='libelle'>Durée totale des visites</span><span class='value'>#{duree_totale}</span>"
    end

    it 'définit la durée totale des visites pour les particuliers' do
      duree_particuliers  = 0
      nombre_particuliers = 0
      Connexions::Connexion.resultats[:per_ip].each do |ip, dip|
        !dip.search_engine? || next
        duree_particuliers += dip.duree_connexion
        nombre_particuliers += 1
      end
      expect(duree_particuliers).to be > 0
      duree_moy = (duree_particuliers / nombre_particuliers).as_horloge
      duree_particuliers = duree_particuliers.as_horloge
      expect(report).to include "<span class='libelle'>Durée visite particuliers</span><span class='value'>#{duree_particuliers} (#{duree_moy}/part.)</span>"
    end

  end

end
