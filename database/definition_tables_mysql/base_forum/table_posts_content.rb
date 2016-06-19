# encoding: UTF-8
=begin

Table pour consigner le contenu des messages

=end
def schema_table_posts_content
  <<-MYSQL
CREATE TABLE posts_content
  (
    id          INTEGER,
    updated_at  INTEGER(10),
    content     TEXT        NOT NULL,

    PRIMARY KEY (id)
  )
  MYSQL
end
