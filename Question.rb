require_relative 'questions_database'
require_relative 'User'
require_relative 'Reply'
require_relative 'Question_follows'
require_relative 'Question_likes'
require_relative 'ModelBase'

class Question < ModelBase
    attr_accessor :id,:title, :body, :user_id
    # def self.all
    #   data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    #   data.map { |datum| Question.new(datum) }
    # end

    # def self.find_by_id(target_id)
    #   data = QuestionsDatabase.instance.execute(<<-SQL, target_id)
    #       SELECT
    #           *
    #       FROM
    #           questions
    #       WHERE
    #           id = ?
    #   SQL
    #   data.map { |datum| Question.new(datum) }[0]
    # end

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

    # def save
    #   if self.id
    #     QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id, self.id)
    #         UPDATE
    #             questions
    #         SET
    #             title = ?, body = ?, user_id = ?
    #         WHERE
    #             id = ?
    #     SQL
    #   else
    #     QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id)
    #         INSERT INTO
    #             questions (title, body, user_id)
    #         VALUES
    #             (?, ?, ?)
    #     SQL
    #     self.id = QuestionsDatabase.instance.last_insert_row_id
    #   end
    # end

    def self.find_by_author_id(author_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT
                *
            FROM
                questions
            WHERE
                user_id = ?
        SQL
        data.map { |datum| Question.new(datum) }
      end

      def author
        User.find_by_id(self.user_id)
      end

      def replies
        Reply.find_by_question_id(self.id)
      end

      def followers
        QuestionFollow.followers_for_question_id(self.id)
      end

      def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
      end

      def likers
        QuestionLike.likers_for_question_id(self.id)
      end

      def num_likes
        QuestionLike.num_likes_for_question_id(self.id)
      end

      def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
      end
  end
