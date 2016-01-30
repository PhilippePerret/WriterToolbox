# encoding: UTF-8
class Forum
  class << self

    # Pour les données générales des messages
    def table_posts
      @table_posts ||= site.db.create_table_if_needed('forum', 'posts')
    end
    # Pour le contenu des messages
    def table_posts_content
      @table_posts_content ||= site.db.create_table_if_needed('forum', 'posts_content')
    end
    # Pour les votes
    def table_posts_votes
      @table_posts_votes ||= site.db.create_table_if_needed('forum', 'posts_votes')
    end

    def table_sujets
      @table_sujets ||= site.db.create_table_if_needed('forum', 'sujets')
    end
    def table_sujets_posts
      @table_sujets_posts ||= site.db.create_table_if_needed('forum', 'sujets_posts')
    end

    def table_categories
      @table_categories ||= site.db.create_table_if_needed('forum', 'categories')
    end

    def table_users
      @table_users ||= site.db.create_table_if_needed('forum', 'users')
    end

    # {SQLite3::Databalse} Base de données du forum. Pour injection
    # directe de code.
    def db
      @db ||= site.db.database_of('forum')
    end


  end # << self
end #/Forum
