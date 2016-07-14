# encoding: UTF-8
#
# Module qui va produire le rapport de connexion pour l'administration.
class CRON2
    class ConnexionsReport
        attr_reader :report

        def initialize
            @report = Hash.new
            @report = {
                by_ip:    Hash.new,
                message:  nil,
                titre:    nil
            }
        end


        # Construction du rapport
        def build_report
            recolte_connexions_by_ip
            rationalise_connexions
            build_message_admin
        end

        # Envoi du rapport à l'administrateur:
        def send_report
            log "   -> Envoi du rapport de connexion à l'administration"
            log "      Mail : #{site.mail}"
            res = site.send_mail(
                to:         site.mail,
                from:       site.mail,
                subject:    report[:titre],
                message:    report[:message],
                formated:   true
            )
            if res === true
                log "    <- OK Rapport envoyé avec succès"
                CRON2::Histo.add(code: '20101')
            else
                mess_err = ["# ERREUR EN TRANSMETTANT LE RAPPORT :"]
                mess_err << res.message
                mess_err += res.backtrace
                mess_err = "    " + mess_err.join("\n    ")
                log mess_err
                log "    <- SiteHtml::Connexions::send_report"
            end
        end

        # On consigne le rapport dans un fichier
        def consigne_report
            folder_rapports = "#{THIS_FOLDER}/rapports_connexions"
            `mkdir -p #{folder_rapports}`
            ntime = Time.now.strftime("%d_%m_%Y-%H-%M")
            path_rapport = File.join(folder_rapports, "connexions-#{ntime}")
            File.open(path_rapport, 'wb'){ |f|
                f.puts report[:titre]
                f.puts report[:message]
            }
        end

        # À la fin de l'opération on peut détruire toutes les connexions
        # actuelles pour repartir de zéro.
        def remove_connexions
            table_connexions_per_ip.delete(where: "time <= #{@start_time}")
        end

        # La table contenant les connexions provisoires
        def table_connexions_per_ip
            @table_connexions_per_ip ||= site.dbm_table(:hot, 'connexions_per_ip')
        end

        # ---------------------------------------------------------
        # Méthodes fonctionnelles
        # ---------------------------------------------------------

        def recolte_connexions_by_ip
            # On récupère toutes les connexions qui ont eu lieu depuis
            # le dernier rapport.
            all_connexions = table_connexions_per_ip.select
            # On définit le temps de départ à maintenant pour supprimer
            # toutes ces connexions en fin de rapport, si tout s'est
            # bien passé
            @start_time = Time.now.to_i
            all_connexions.each do |con|
                ip = con[:ip]
                @report[:by_ip][ip] ||= {times: Array::new, routes: Array::new}
                @report[:by_ip][ip][:times]   << con[:time]
                @report[:by_ip][ip][:routes]  << con[:route]
            end

        end

        # Retourne TRUE si des connexions ont été trouvées. Dans le
        #   # cas contraire, aucun mail n'est envoyé et aucun rapport
        #     # n'est à consigner.
        #
        def has_connexions?
            report[:by_ip].count > 0
        end
        def build_message_admin
            titre = "Rapport #{ONLINE ? 'ONLINE' : 'OFFLINE'} des connexions du #{Time.now}"

            mess = ''

            ip_entete     = "IP".ljust(20)
            nb_entete     = "Nb".ljust(4)
            duree_entete  = "Durée".ljust(5)
            whois_entete  = "Whois".ljust(30)
            from_entete   = "De".ljust(8)
            to_entete     = "à".ljust(8)
            route_entete  = "Routes".ljust(5)
            entete = "#{ip_entete} #{nb_entete} #{duree_entete} #{whois_entete} #{from_entete} #{to_entete} #{route_entete}"

            known_ips   = {}
            unknown_ips = []

            @report[:by_ip].each do |ip, ipdata|
                ip_str = ip.ljust(20)
                nb_str = ipdata[:nombre_connexions].to_s.ljust(4)
                first_str   = Time.at(ipdata[:first_connexion_time]).strftime("%H:%M:%S")
                last_str    = Time.at(ipdata[:last_connexion_time]).strftime("%H:%M:%S")
                duree       = ipdata[:last_connexion_time] - ipdata[:first_connexion_time]
                duree_str   = duree.to_s.ljust(5)
                pseudo_ipdata = pseudo_in_ipdata(ipdata)
                whois_str   = pseudo_ipdata.ljust(30)
                routes_str  = ipdata[:nombre_routes].to_s.rjust(5)

                data_line = "#{ip_str} #{nb_str} #{duree_str} #{whois_str} #{first_str} #{last_str} #{routes_str}"
                if pseudo_ipdata == '- unknown -'
                    unknown_ips << data_line
                else
                    known_ips.key?(pseudo_ipdata) || known_ips.merge!(pseudo_ipdata => [])
                    known_ips[pseudo_ipdata] << data_line
                end
            end

            mess = "\nNombre total d'IPs : #{@report[:by_ip].count}"
            mess += "\nIPs connues : #{known_ips.count}"
            mess += "\nIPs inconnues : #{unknown_ips.count}"

            known_ips     = known_ips.collect{ |nom, arr| arr.join("\n") }.join("\n")
            unknown_ips   = unknown_ips.sort.join("\n")

            mess += "\n=== IPs INCONNUES ===\n"
            mess += unknown_ips
            mess += "\n\n\n=== IPs CONNUES ===\n"
            mess += known_ips

            mess += "\n\n=== ROUTES PAR IPS ===\n"
            mess += @report[:by_ip].collect do |ip, ipdata|
                "#{ip} #{pseudo_in_ipdata ipdata}\n" +
                    ipdata[:routes].collect do |route|
                    route_linked = "<a href=\"http://www.laboiteaoutilsdelauteur.fr/#{route}\">#{route}</a>"
                    "\t- #{route_linked}"
                    end.join("\n")
            end.join("\n\n")

            mess = "<pre style='font-size:9pt'>\n#{titre}\n\n#{entete}\n#{mess}\n</pre>"
            @report[:message] = mess + message_sous_rapport
            @report[:titre]   = titre
        end

        def pseudo_in_ipdata ipdata
            whois = ipdata[:whois]
            case whois
            when NilClass then "- unknown -"
            when String   then whois
            when Hash
                if whois.key?(:pseudo)
                    whois[:short_pseudo] || whois[:pseudo]
                elsif whois.key?(:id)
                    User.get(whois[:id]).pseudo
                elsif whois.key?(:user_id)
                    User.get(whois[:user_id]).pseudo
                else
                    "INCONNU AVEC CLÉS #{whois.keys.join(', ')}"
                end
            else
                "- unknown & unfoundable (whois est #{whois.class}) -"
            end
        end

        def message_sous_rapport
            <<-HTML
            <p class='small'>La durée est exprimée en secondes.</p>
            <p class='small'>Ces rapports de connexions peuvent être récupérés en fichier dans le dossier `./CRON/rapports_connexions/`.</p>
            HTML
        end

        def rationalise_connexions
            @report[:by_ip].each do |ip, ipdata|

                times   = ipdata[:times]
                routes  = ipdata[:routes].uniq

                whois = nil
                if known_ips.key?(ip)
                    whois = known_ips[ip]
                else
                    search_engine_ips.each do |mid, mdata|
                        mdata[:ips].each do |cip|
                            if cip =~ ip
                                whois = mdata[:short_pseudo] || mdata[:pseudo]
                                break
                            end
                        end
                        break if whois
                    end
                end

                @report[:by_ip][ip].merge!(
                    ip:                   ip,
                    whois:                whois,
                    nombre_connexions:    times.count,
                    first_connexion_time: times.min,
                    last_connexion_time:  times.max,
                    routes:               routes, # uniques, ici
                    nombre_routes:        routes.count
                )
            end
        end

        def known_ips
            @known_ips ||= begin
                               require './data/secret/known_ips.rb'
                               KNOWN_IPS
                           end
        end

        def search_engine_ips
            @search_engine_ips ||= SEARCH_ENGINES_IPS_LIST
        end

    end
end
