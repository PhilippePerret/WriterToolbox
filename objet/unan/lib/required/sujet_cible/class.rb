# encoding: UTF-8
=begin

class Unan::SujetCible
----------------------
Gestion des sujets cibles

=end
class Unan
class SujetCible

  class << self

    # Reçoit la valeur (value) du juste principal (premier niveau de
    # SUJETS_CIBLES) et retourne les données (contenant hname et value)
    def get_cate_by_value value
      @sujets_cibles_by_values ||= begin
        h = Hash::new
        SUJETS_CIBLES.each do |cid, cdata|
          h.merge!(cdata[:value] => cdata.merge(id: cid))
        end
        h
      end
      @sujets_cibles_by_values[value]
    end

    # +cate_id+ {Symbol} Identifiant de la catégorie générale
    # +value+   {Fixnum} Valeur de la sous-categorie
    def get_subcate_by_value cate_id, value
      data_cate = SUJETS_CIBLES[cate_id]
      data_cate[:sub].each do |scid, scdata|
        return scdata.merge(id: scid) if scdata[:value] == value
      end
    end
    def get_subcate_by_id cate_id, scate_id
      data_cate = SUJETS_CIBLES[cate_id]
      data_cate[:sub][scate_id]
    end

    def sujet_hname value
      case value
      when Symbol then SUJETS_CIBLES[value]
      when Fixnum then get_cate_by_value(value)
      end[:hname]
    end

    def sous_sujet_hname cate_id, value
      return nil if value == "-"
      cate_id = case cate_id
      when Symbol then cate_id
      when Fixnum then get_cate_by_value(cate_id)[:id] # par valeur
      end

      case value
      when Symbol then get_subcate_by_id(cate_id, value)
      when Fixnum then get_subcate_by_value(cate_id, value)
      end[:hname]

    end
  end # /<< self
end #/SujetCible
end #/Unan
