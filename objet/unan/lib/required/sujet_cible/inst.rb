# encoding: UTF-8
=begin

Instances Unan::SujetCible

@usage

    sc = Unan::SujetCible::new <arguments>

    <arguments> :

        Soit valeur-sujet, valeur-sous-sujet      new(2,5)
        Soit "<val-sujet><val-subsujet>"          new("25")
        Soit :id-sujet, :id-sous-sujet            new(:projet, :presentation)
        Soit :id-sujet, <val-sous-sujet>          new(:projet, 5)
        Soit <val-sujet>, :id-sous-sujet          new(2, :presentation)

  Ensuite :

      sc.human_name (ou hname) retourne le nom humain au format :
                    "Sujet::Sous-sujet"
=end
class Unan
class SujetCible

  attr_reader :data_sujet
  attr_reader :data_sub_sujet

  # Initialisation
  # Soit par un seul argument, quelque chose comme "48"
  #   où "4" est la valeur du sujet
  #   et "8" est la valeur du sous-sujet
  # Soit par deux arguments, soit {Fixnum} la valeur du sujet ou
  # {Symbol} L'id du sujet et, soit {Fixnum} la valeur du sous-sujet
  # ou {Symbol} l'id du sous-sujet
  def initialize sc_ref, sc_sub = nil
    if sc_sub.nil?
      raise ArgumentError, "Mauvais premier argument pour Unan::SujetCible::new" unless sc_ref.instance_of?(String) && sc_ref.length == 2
      sc_sub = sc_ref[1].to_s # "-" ou 0-9
      sc_sub = sc_sub.to_i if sc_sub != '-'
      sc_ref = sc_ref[0].to_i
    end

    @data_sujet = case sc_ref
    when Fixnum then self.class::get_cate_by_value(sc_ref)
    when Symbol then SUJETS_CIBLES[sc_ref].merge(id: sc_ref)
    else raise ArgumentError, "Mauvais premier argument pour Unan::SujetCible::new"
    end

    @data_sub_sujet = case sc_sub
    when Fixnum   then self.class::get_subcate_by_value(sujet_id, sc_sub)
    when Symbol   then @data_sujet[:sub][sc_sub].merge(id: sc_sub)
    when "-"      then {}
    else raise ArgumentError, "Mauvais second argument pour Unan::SujetCible::new"
    end

  end

  def sujet_id
    @sujet_id ||= data_sujet[:id]
  end

  def sub_sujet_id
    @sub_sujet_id ||= data_sub_sujet[:id]
  end

end #/SujetCible
end #/Unan
