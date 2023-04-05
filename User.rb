require_relative 'questions_database'

class User
    attr_accessor :id,:fname, :lname
  ​
    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM users")
      data.map { |datum| User.new(datum) }
    end
  ​
    def self.find_by_id(target_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, target_id)
          SELECT
              *
          FROM
              users
          WHERE
              id = ?
      SQL
      data.map { |datum| User.new(datum) }[0]
    end
  ​
    def self.find_by_name(fname,lname)
      data = QuestionsDatabase.instance.execute(<<-SQL, fname,lname)
          SELECT
              *
          FROM
              users
          WHERE
              users.fname = ?
              AND users.lname = ?
      SQL
      data.map { |datum| User.new(datum) }
    end
  ​
    def initialize(options)
      @id = options['id']
      @fname = options['fname']
      @lname = options['lname']
    end
  ​
    def create
      raise "#{self} already in database" if self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  ​
    def update
      raise "#{self} not in database" unless self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    end
  end