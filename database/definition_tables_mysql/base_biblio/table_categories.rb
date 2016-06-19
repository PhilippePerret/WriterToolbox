# encoding: UTF-8
=begin

=end
def schema_table_categories
  <<-MYSQL
CREATE TABLE categories
  (
    id          INTEGER       AUTO_INCREMENT,
    cate_id     VARCHAR(4)    UNIQUE,
    hname       VARCHAR(255)  NOT NULL,
    description TEXT,
    PRIMARY KEY (id)
  )
  MYSQL
end
