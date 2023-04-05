require_relative 'questions_database'
require_relative 'User'
require_relative 'Question'
require_relative 'ModelBase'

class Reply < ModelBase
    attr_accessor :id,:user_id, :question_id, :reply_id, :body

    # def self.all
    #   data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    #   data.map { |datum| Reply.new(datum) }
    # end

    # def self.find_by_id(id)
    #   data = QuestionsDatabase.instance.execute(<<-SQL, id)
    #       SELECT
    #           *
    #       FROM
    #         replies
    #       WHERE
    #         id = ?
    #   SQL
    #   data.map { |datum| Reply.new(datum) }[0]
    # end


    def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @user_id = options['user_id']
      @reply_id = options['reply_id']
      @body = options['body']
    end

    def save
        if self.id
            QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.reply_id, self.user_id, self.body, self.id)
                UPDATE
                    replies
                SET
                    question_id = ?, reply_id = ?, user_id = ?, body = ?
                WHERE
                    id = ?
            SQL
        else
            QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.reply_id, self.user_id, self.body)
                INSERT INTO
                    replies (question_id, reply_id, user_id, body)
                VALUES
                    (?, ?,?,?)
            SQL
            self.id = QuestionsDatabase.instance.last_insert_row_id
        end
    end

    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
              replies
            WHERE
              user_id = ?
        SQL
        data.map { |datum| Reply.new(datum) }
      end

      def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
              replies
            WHERE
              question_id = ?
        SQL
        data.map { |datum| Reply.new(datum) }
      end

      def author
        User.find_by_id(self.user_id)
      end

      def question
        Question.find_by_id(self.question_id)
      end

      def parent_reply
        return nil if reply_id.nil?
        Reply.find_by_id(reply_id)
      end

      def child_replies
        Reply.all.select do |child|
            child.reply_id == self.id
        end
    end
  end
