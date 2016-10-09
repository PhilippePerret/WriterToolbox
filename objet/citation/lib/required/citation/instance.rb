# encoding: UTF-8
class Citation

  include MethodesMySQL

  attr_reader :id

  def initialize id
    @id = id
  end

  def citation    ; @citation     ||= get(:citation)    end
  def auteur      ; @auteur       ||= get(:auteur)      end
  def source      ; @source       ||= get(:source)      end
  def description ; @description  ||= get(:description) end
  def last_sent   ; @last_sent    ||= get(:last_sent)   end
  def bitly       ; @bitly        ||= get(:bitly)       end
  def created_at  ; @created_at   ||= get(:created_at)  end


  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------
  def long_url
    @long_url = "#{site.distant_url}/citation/#{id}/show"
  end

  def short_url
    @short_url ||= begin
      self.bitly || begin
        site.require_objet 'bitly'
        rsbitly = RSBitly.new
        rsbitly.long_url = long_url
        rsbitly.short_url # la crée si nécessaire
      end
    end
  end

  def source_humaine
    @source_humaine ||= begin
      if source.nil?
        ""
      else
        source.in_div(class: 'right small italic')
      end
    end
  end

  def boutons_edition
    user.manitou? || ( return '' )
    (
      'Nouvelle citation'.in_a(href: 'http://localhost/WriterToolbox/citation/edit') +
      "Editer la citation ##{id}".in_a(href: "http://localhost/WriterToolbox/citation/#{id}/edit") +
      '&lt;CODES&gt;'.in_a(onclick:"UI.clip({'Route':'citation/#{id}/show', 'Balise':'CITATION[#{id}|voir citation]', 'HREF':'#{site.distant_url}/citation/#{id}/show'})")
    ).in_div(class: 'small right btns')
  end

  def description_if_any
    @description_if_any ||= begin
      if description.nil? || description == ''
        ''
      else
        'Explicitation'.in_h4(class: 'libelle', style: 'margin-top: 4em') +
        humain_description.in_div(id: 'explicitation_citation')
      end
    end
  end

  def humain_description
    @humain_description ||= begin
      description.formate_balises_propres.formate_balises_erb
    end
  end

  def table
    @table ||= self.class.table_citations
  end

end
