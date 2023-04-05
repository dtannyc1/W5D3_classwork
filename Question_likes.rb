require_relative 'questions_database'

class QuestionLikes
    attr_accessor :id,:user_id, :question_id
  ​
    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
      data.map { |datum| QuestionLikes.new(datum) }
    end
  ​
    def self.find_by_user_id(user_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
          SELECT
              *
          FROM
            question_likes
          WHERE
            user_id = ?
      SQL
      data.map { |datum| QuestionLikes.new(datum) }[0]
    end
  ​
    def self.find_by_question_id(question_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
          SELECT
              *
          FROM
            question_likes
          WHERE
          question_id = ?
              
      SQL
      data.map { |datum| QuestionLikes.new(datum) }
    end
  ​
    def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @user_id = options['user_id']
    end
  ​
    def create
      raise "#{self} already in database" if self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.user_id, self.question_id)
        INSERT INTO
          question_likes (user_id,question_id)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  ​
    def update
      raise "#{self} not in database" unless self.id
      QuestionsDatabase.instance.execute(<<-SQL, self.user_id, self.question_id, self.id)
        UPDATE
          question_likes
        SET
          user_id = ?, question_id = ?
        WHERE
          id = ?
      SQL
    end
  end