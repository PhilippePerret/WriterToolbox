# encoding: UTF-8
class TestForum
  class << self

    def remove_all_sujets
      table_sujets.delete
    end
    def remove_all_posts
      table_posts.delete
      table_posts_content.delete
    end
    # Retourne la liste de tous les sujets
    def sujets filtre = nil
      drequest = Hash.new
      drequest.merge!(filtre) unless filtre.nil?
      drequest.merge!(colonnes: [:titre])
      table_sujets.select(drequest).collect{|h| h[:titre]}
    end
    def table_sujets
      @table ||= site.dbm_table(:forum, 'sujets')
    end
    def table_posts
      @table_posts ||= site.dbm_table(:forum, 'posts')
    end
    def table_posts_content
      @table_posts_content ||= site.dbm_table(:forum, 'posts_content')
    end
  end #/<< self (TestForum)

  # ---------------------------------------------------------------------
  #   Class TestForum::Sujet
  # ---------------------------------------------------------------------
  class Sujet
    # Titre du sujet, de la question
    attr_reader :titre
    def initialize titre
      @titre = titre
    end
    # ---------------------------------------------------------------------
    #   Méthodes de données directes
    # ---------------------------------------------------------------------
    def id;       @id       ||= data[:id]       end
    def options;  @options  ||= data[:options]  end
    def data;   @data   ||= get_data  end

    def get_data
      TestForum.table_sujets.get(where: {titre: titre})
    end
    # ---------------------------------------------------------------------
    #   Méthodes de données indirectes
    # ---------------------------------------------------------------------
    def posts filtre = nil, options = nil
      filtre ||= Hash.new
      filtre.merge!(where: "sujet_id = #{id}")
      drequest = Hash.new
      drequest.merge!(filtre)
      drequest.merge!(options) unless options.nil?
      TestForum.table_posts.select(drequest)
    end
    # ---------------------------------------------------------------------
    #   Méthodes de test
    # ---------------------------------------------------------------------
    def napas_de_messages
      if posts.count == 0
        success "Le sujet “#{titre}” n'a aucun message (OK)." if verbose?
      else
        raise "Le sujet “#{titre}” ne devrait avoir aucun message."
      end
    end
    def a_des_messages options
      if options.key?(:count)
        count = options.delete(:count)
        if postscount == count
          success "Il y a #{count} message(s) dans le sujet “#{titre}”." if verbose?
        else
          raise "Il devrait y avoir #{count} message(s), il y en a #{posts.count}."
        end
      end
    end
    # /a_des_messages

    def est_valided
      if options[0].to_i == 1
        success "Le sujet est validé." if verbose?
      else
        raise "Le sujet “#{titre}” devrait être validé."
      end
    end
    def nestpas_valided
      if options[0].to_i == 0
        success "Le sujet n'est pas validé (OK)." if verbose?
      else
        raise "Le sujet “#{titre}” ne devrait pas être validé."
      end
    end
  end
end#/TestForum

# Grande méthode pour détruire tous les éléments du forum
def forum_remove_all
  TestForum.remove_all_sujets
  TestForum.remove_all_posts
end


def le_forum_a_le_sujet sujet, options = nil
  expect(TestForum.sujets(options)).to include sujet
  success "Le forum possède le sujet/question “#{sujet}”." if verbose?
end

def le_sujet_forum sujet_titre
  TestForum::Sujet.new(sujet_titre)
end
