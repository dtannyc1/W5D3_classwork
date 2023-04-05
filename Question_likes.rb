require_relative 'questions_database'
require_relative 'User'
require_relative 'Question'

class QuestionLike
    attr_accessor :id,:user_id, :question_id

    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
      data.map { |datum| QuestionLike.new(datum) }
    end

    def self.find_by_user_id(user_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
          SELECT
              *
          FROM
            question_likes
          WHERE
            user_id = ?
      SQL
      data.map { |datum| QuestionLike.new(datum) }
    end

    def self.find_by_question_id(question_id)
      data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
          SELECT
              *
          FROM
            question_likes
          WHERE
          question_id = ?

      SQL
      data.map { |datum| QuestionLike.new(datum) }
    end

    def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @user_id = options['user_id']
    end

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

    def self.likers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
              users.id, users.fname, users.lname
            FROM
              question_likes
            JOIN
              users ON users.id = question_likes.user_id
            WHERE
              question_id = ?
        SQL
        data.map { |datum| User.new(datum) }
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
              COUNT(*) AS num
            FROM
              question_likes
            JOIN
              users ON users.id = question_likes.user_id
            WHERE
              question_id = ?
        SQL
        data[0]["num"]
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
              questions.id, questions.title, questions.body, questions.user_id
            FROM
              question_likes
            JOIN
              questions ON questions.id = question_likes.question_id
            WHERE
              question_likes.user_id = ?
        SQL
        data.map { |datum| Question.new(datum) }
    end

    def self.most_liked_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT
              questions.id, questions.title, questions.body, questions.user_id
            FROM
              question_likes
            JOIN
              questions ON questions.id = question_likes.question_id
            GROUP BY
              question_id
            ORDER BY
              COUNT(*) DESC
            LIMIT
              ?
        SQL
        data.map { |datum| Question.new(datum) }
    end

  end
