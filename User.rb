require_relative 'questions_database'
require_relative 'Questions'
require_relative 'Replies'
require_relative 'Question_follows'
require_relative 'Question_likes'

class User
    attr_accessor :id, :fname, :lname

    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM users")
      data.map { |datum| User.new(datum) }
    end

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
      data.map { |datum| User.new(datum) }[0]
    end

    def initialize(options)
      @id = options['id']
      @fname = options['fname']
      @lname = options['lname']
    end

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

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Replies.find_by_user_id(self.id)
    end

    def average_karma   
        data = QuestionsDatabase.instance.execute(<<-SQL,self.id)
            SELECT
                AVG(num_likes_per_q.num_likes) AS avg_karma
            FROM
                (
                    Select   --all the ques that the user has asked 
                       COUNT(*) AS num_likes
                    From
                        questions
                    Where
                        questions.user_id = ?
                    LEFT JOIN 
                        question_likes ON question_likes.question_id = questions.id
                    GROUP BY
                        questions.id

                ) AS num_likes_per_q
            
        SQL
        data[0]['avg_karma']
        end


    def followed_questions
        QuestionFollows.followed_questions_for_user_id(self.id)
    end

    def liked_questions
        QuestionLikes.liked_questions_for_user_id(self.id)
    end

  end
