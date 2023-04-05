require_relative 'questions_database'

class Question
    attr_accessor :id,:title, :body, :user_id
    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
      data.map { |datum| Question.new(datum) }
    end

    def self.find_by_id(target_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, target_id)
          SELECT
              *
          FROM
              questions
          WHERE
              id = ?
      SQL
      data.map { |datum| Question.new(datum) }[0]
    end

    def self.find_by_title(title)
      data = QuestionsDatabase.instance.execute(<<-SQL, title)
          SELECT
              *
          FROM
              questions
          WHERE
              questions.title = ?
              
      SQL
      data.map { |datum| Question.new(datum) }
    end

    def initialize(options)
      @id = options['id']
      @title = options['title']
      @body = options['body']
      @user_id = options['user_id']
    end

    def create
      raise "#{self} already in database" if self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id)
        INSERT INTO
          questions (title, body, user_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
      raise "#{self} not in database" unless self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id, self.id)
        UPDATE
          questions
        SET
          title = ?, body = ?, user_id = ?
        WHERE
          id = ?
      SQL
    end
  end