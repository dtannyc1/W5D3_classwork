require_relative 'questions_database'

class Replies
    attr_accessor :id,:user_id, :question_id, :reply_id, :body

    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
      data.map { |datum| Replies.new(datum) }
    end

    def self.find_by_id(id)
      data = QuestionsDatabase.instance.execute(<<-SQL, id)
          SELECT
              *
          FROM
            replies
          WHERE
            id = ?
      SQL
      data.map { |datum| Replies.new(datum) }[0]
    end


    def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @user_id = options['user_id']
      @reply_id = options['reply_id']
      @body = options['body']
    end

    def create
      raise "#{self} already in database" if self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.reply_id, self.user_id, self.body)
        INSERT INTO
          replies (question_id, reply_id, user_id, body)
        VALUES
          (?, ?,?,?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
      raise "#{self} not in database" unless self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.reply_id, self.user_id, self.body, self.id)
        UPDATE
          replies
        SET
          question_id = ?, reply_id = ?, user_id = ?, body = ?
        WHERE
          id = ?
      SQL
    end
  end
