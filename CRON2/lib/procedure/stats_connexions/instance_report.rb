# encoding: UTF-8
#
# Module qui va produire le rapport de connexion pour l'administration.
class CRON2
    class ConnexionsReport
        attr_reader :report

        def initialize
            @report = Hash.new
            @report = {
                by_ip:    Hash::new,
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
