# encoding: UTF-8
#
# Module gérant l'historique des crons job
# C'est lui qui assure l'enregistrement des travaux des
# cronjob
#
# @usage
#     CRON2::Histo.add(:code => <le code 5 chiffres>)
#
#   Valeurs optionnelles :
#     :intitule (si non défini dans CODES ci-dessous)
#     :description
#
class CRON2
  class Histo

    # Définition des codes 5 chiffres
    # :intitule     L'intitulé par défaut, quand n'est pas précisé
    # :data         Ce qui est enregistré dans la propriété :data
    # :description  Ce qui est enregistré dans la propriété :description
    #
    # :full_intitule    Si défini, servira pour l'affichage du rapport de
    #                   cron pour l'administrateur. Toutes les valeurs templates
    #                   utilisables se trouvent dans `as_hash` de la définition
    #                   de l'opération cron, dans ./objet/admin/cron_report.rb
    #                   Mettre à FALSE pour que l'opération ne soit pas affichée
    #                   dans le rapport.
    CODES = {
      '00000' => {value: '00000', intitule: 'Opération non définie', hname: 'Non défini'},
      '31001' => {value: '31001', intitule: 'Mail actualités', hname: 'actualités', data: 'Nombre d’envois', description: 'Mail envoyé',
        full_intitule: 'Mail actualités envoyé à %{data} personnes'},
      '31021' => {value: '31021', intitule: 'Erreur envoi mail actualités', hname: 'actualités', data: nil, description: 'Erreur rencontrée',
        full_intitule: 'Erreur lors de l’envoi des mails d’actualités : %{description}'},
      '11100' => {value: '11100', intitule: 'Nettoyage du site', hname: 'Nettoyage', data: 'Nombre de fichiers détruits', description: nil,
        full_intitule: false},
      '20101' => {value: '20001', intitule: 'Rapport des connexions', hname: 'Connexions', data: nil, description: nil,
        full_intitule: 'Établissement du rapport des connexions'},
      '25101' => {value: '25101', intitule: 'Envoi d’une citation', hname: 'Citation', data: 'ID de la citation envoyée', description: nil,
        full_intitule: 'Envoi de la citation #%{data}'},
      '25121' => {value: '25121', intitule: 'Erreur lors de l’envoi d’une citation', hname: 'Citation error', data: 'Message d’erreur', description: nil,
        full_intitule: 'Erreur majeure : impossible d’envoyer la citation : #%{data}'},
      '26101' => {value: '26101', intitule: 'Envoi d’un tweet permanent', hname: 'Tweet permanent', data: 'IDs des tweets envoyé', description: nil,
        full_intitule: 'Tweet permanent #%{data} envoyé à %{hour} heures.'},
      '26121' => {value: '26121', intitule: 'Erreur lors de l’envoi d’un tweet permanent', hname: 'Tweet permanent error', data: 'Message d’erreur', description: nil,
        full_intitule: 'Erreur majeure : impossible d’envoyer le tweet permanent : #%{data}.'},
      '77201' => {value: '77201', intitule: 'Rapport quotidien à un auteur UAUS', hname: 'Rapport Unan', data: 'ID de l’auteur', description: nil,
        full_intitule: 'Rapport UNAN envoyé avec succès à %{user_in_data}'},
      '41300' => {value: '41300', intitule: 'Destruction d’une autorisation (abonnement ou autre)', hname: 'Autorisation', data: 'IDs autorisations détruites', description: nil}
    }

    # --- Définition des 5 valeurs du code ---
    CODE = [
      [ # bit 0 (cible de l'opération)
        {bit: 0, value: 0, svalue: :none        },
        {bit: 0, value: 1, svalue: :site        },
        {bit: 0, value: 2, svalue: :user        },
        {bit: 0, value: 3, svalue: :inscrits    },
        {bit: 0, value: 4, svalue: :abonnes     },
        {bit: 0, value: 5, svalue: :admin       },
        {bit: 0, value: 6, svalue: :analyste    },
        {bit: 0, value: 7, svalue: :auteur_unan }
      ],
      [ # bit 1 (sujet)
        {bit: 1, value: 0, svalue: :none      },
        {bit: 1, value: 1, svalue: :site      },
        {bit: 1, value: 2, svalue: :narration },
        {bit: 1, value: 3, svalue: :analyse   },
        {bit: 1, value: 4, svalue: :unan      },
        {bit: 1, value: 5, svalue: :citations },
        {bit: 1, value: 6, svalue: :tweets    },
        {bit: 1, value: 7, svalue: :rapport   }
      ],
      [ # bit 2 (type d'opération)
        {bit: 2, value: 0, svalue: :none},
        {bit: 2, value: 1, svalue: :files},
        {bit: 2, value: 2, svalue: :mail},     # un envoi par mail
        {bit: 3, value: 3, svalue: :status, desc: 'Changement de statut'}
      ],
      [ # bit 3 (type d'erreur)
        # METTRE IMPÉRATIVEMENT LE BIT 3 À UNE VALEUR > 0 POUR LES
        # ERREURS
        {bit: 3, value: 0, svalue: :none},
        {bit: 3, value: 1, svalue: :minor_error},
        {bit: 3, value: 2, svalue: :main_error},
        {bit: 3, value: 3, svalue: :fatal_error}
      ],
      [ # bit 4
        {bit: 4, value: 0, svalue: :none}
      ]
    ]


    # ---------------------------------------------------------------------
    #   CLASS
    # ---------------------------------------------------------------------
    class << self

      # Ajout d'une ligne d'historique
      # +hdata+ est un Hash qui contient au minimum
      #   :code
      # Optionnellement:
      #  :intitule, :description
      #
      def add hdata
        new(hdata).create
      end
    end # /<<self


    # Les données transmises pour instancier la ligne1
    attr_reader :data

    # Instanciation d'une ligne d'historique, donc d'une rangée
    # dans la table :cold, 'cron'
    #
    # +data+
    #   :code           Code sur 5 chiffres (cf. CODE ci-dessus)
    #   :intitule       Intitulé de l'opération
    #   :description    Description précise
    #
    def initialize data
      @data = data
    end

    # Création de la donnée historique
    def create
      @id = table.insert(data2save)
    end

    # ---------------------------------------------------------------------
    #   Data
    # ---------------------------------------------------------------------
    def code
      @code ||= begin
        if data
          data[:code]
        else
          nil
        end
      end
    end
    def intitule
      @intitule ||= begin
        if data && data[:intitule]
          data[:intitule]
        elsif code && CRON2::Histo::CODES[code]
          CRON2::Histo::CODES[code][:intitule]
        else
          "[pas d'intitulé pour code #{code.inspect}]"
        end
      end
    end
    def description
      @description ||= data[:description]
    end

    # Les données à enregistrer dans la base
    def data2save
      @data2save ||= {
        code:         code, # code de 5 chiffres
        intitule:     intitule,
        description:  description,
        data:         data[:data],
        created_at:   NOW
      }
    end

    def table
      @table ||= site.dbm_table(:cold, 'cron')
    end
  end #/CRON2::Histo
end #/CRON2
