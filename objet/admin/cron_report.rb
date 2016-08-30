# encoding: UTF-8
raise_unless_admin

# Pour les codes d'historique
require './CRON2/lib/required/historique.rb'

class CronReport
  include Singleton

  attr_accessor :current_day
  attr_accessor :current_hour

  # = main =
  #
  # Méthode qui retourne le rapport des derniers jours
  def report
    last_operations.collect do |hope|
      cronope = CronOpe.new(hope)
      cronope.in_rapport? || next
      cronope.as_line
    end.compact.join("\n").in_pre(class: 'small')
  end

  def last_operations
    @last_operations ||= begin
      avant_hier = NOW - 2.days
      table.select(where: "created_at > #{avant_hier}", order: 'created_at ASC')
    end
  end

  def table
    @table ||= site.dbm_table(:cold, 'cron', online = true)
  end
end

class CronOpe
  attr_reader :code, :intitule, :description, :data
  attr_reader :created_at
  def initialize instdata
    @instdata = instdata
    instdata.each{|k,v| instance_variable_set("@#{k}", v)}
  end

  # = main =
  #
  # La ligne pour l'affichage dans le rapport
  def as_line
    line_day +
    span_operation
  end
  def span_operation
    "    #{hour_or_not} #{full_intitule}".in_span(class: classe_css)
  end

  # Retourne soit l'heure soit des caractères vides si l'heure
  # est la même que pour l'opération précédente
  def hour_or_not
    if cronreport.current_day == ddmmyyyy && cronreport.current_hour == hour
      return '     '
    else
      cronreport.current_hour = hour
      hour
    end
  end

  def line_day
    if ddmmyyyy == cronreport.current_day
      ''
    else
      cronreport.current_day = ddmmyyyy
      "<strong>#{ddmmyyyy}</strong>\n"
    end
  end

  # Pour le template full_intitule
  def as_hash
    @as_hash ||= {
      code:           code,
      intitule:       intitule,
      description:    description,
      data:           data,
      created_at:     created_at,
      hour:           hour,
      user_in_data:   user_in_data
    }
  end

  def user_in_data
    @user_in_data ||= begin
      # Quand la propriété :data désigne un user, on construit ici sa
      # référence.
      # Noter que cette méthode est toujours appelée pour construire la
      # propriété as_hash, même lorsque @data n'est pas l'id d'un user.
      # On ne doit utiliser %{user_in_data} dans le @full_intitule de la
      # définition du code historique que lorsque la propriété @data contient
      # l'id d'un user (comme pour le rapport UNAN)
      if data.to_s.numeric?
        uid = data.to_i
        huser = site.dbm_table(:hot, 'users', online = true).get(uid)
        if huser != nil
          "#{huser[:pseudo]} (##{uid})"
        end
      end
    end
  end
  def time
    @time ||= Time.at(created_at)
  end
  def hour
    @hour ||= time.strftime('%H:%M')
  end
  def ddmmyyyy
    @ddmmyyyy ||= time.strftime('%d %m %Y')
  end

  def classe_css
    error? ? 'red' : nil
  end

  # True si l'opération doit être affichée dans le rapport
  #
  # Pour ne pas afficher l'opération dans le rapport, mettre son
  # :full_intitule à false dans ./CRON2/lib/required/historique.rb
  # (CODES)
  def in_rapport?
    @is_in_rapport ||= !(full_intitule === false)
  end
  # True s'il y a eu une erreur quelconque
  def error?
    @has_error ||= code[3].to_i > 0
  end

  # Retourne true si c'est une erreur
  def fatal_error?
    @is_fatal_error ||= code[3].to_i == 3
  end
  def main_error?
    @is_main_error ||= code[3].to_i == 2
  end
  def minor_error?
    @is_minor_error ||= code[3].to_i == 1
  end

  def data_histo
    @data_histo ||= CRON2::Histo::CODES[code]
  end

  # Retourne l'intitulé complet en fonction du code
  def full_intitule
    if data_histo && data_histo.key?(:full_intitule)
      if data_histo[:full_intitule] === false
        false
      else
        data_histo[:full_intitule] % self.as_hash
      end
    else
      "#{intitule} - #{description}"
    end
  end
end#/CronOpe




def cronreport
  @cronreport ||= CronReport.instance
end
