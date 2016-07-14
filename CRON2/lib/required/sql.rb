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
    CODES = {
      '00000' => {value: '00000', intitule: 'Opération non définie', hname: 'Non défini'},
      '31001' => {value: '31001', intitule: 'Mail actualités', hname: 'actualités', data: 'Nombre d’envois', description: 'Mail envoyé'},
      '11100' => {value: '11100', intitule: 'Nettoyage du site', hname: 'Nettoyage', data: 'Nombre de fichiers détruits', description: nil},
      '20101' => {value: '20001', intitule: 'Rapport des connexions', hname: 'Connexions', data: nil, description: nil},
      '25101' => {value: '25101', intitule: 'Envoi d’une citation', hname: 'Citation', data: 'ID de la citation envoyée', description: nil},
      '26101' => {value: '26101', intitule: 'Envoi d’un tweet permanent', hname: 'Tweet permanent', data: 'IDs des tweets envoyé', description: nil},
      '77201' => {value: '77201', intitule: 'Rapport quotidien à un auteur UAUS', hname: 'Rapport Unan', data: 'ID de l’auteur', description: nil}
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
        {bit: 2, value: 2, svalue: :mail}     # un envoi par mail
      ],
      [ # bit 3
        {bit: 3, value: 0, svalue: :none}
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
        data[:code]
      end
    end
    def intitule
      @intitule ||= data[:intitule] || CRON2::Histo::CODES[code][:intitule]
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
        created_at:   NOW
      }
    end

    def table
      @table ||= site.dbm_table(:cold, 'cron')
    end
  end #/CRON2::Histo
end #/CRON2
