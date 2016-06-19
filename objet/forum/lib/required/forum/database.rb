# encoding: UTF-8
class Forum
  class << self

    def table_users
      @table_users ||= site.dbm_table(:forum, 'users')
    end
    # Tous les messages (moins les contenus)
    def table_posts
      @table_posts ||= site.dbm_table(:forum, 'posts')
    end
    # Pour le contenu des messages
    def table_posts_content
      @table_posts_content ||= site.dbm_table(:forum, 'posts_content')
    end
    # Pour les votes
    def table_posts_votes
      @table_posts_votes ||= site.dbm_table(:forum, 'posts_votes')
    end
    def table_sujets
      @table_sujets ||= site.dbm_table(:forum, 'sujets')
    end
    def table_follows
      @table_follows ||= site.dbm_table(:forum, 'follows')
    end

  end # << self
end #/Forum
