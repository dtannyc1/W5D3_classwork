require 'active_support/inflector'
require_relative 'questions_database'

class ModelBase
    def self.find_by_id(target_id)
        table = self.to_s.tableize
        data = QuestionsDatabase.instance.execute(<<-SQL, target_id)
            SELECT
                *
            FROM
                #{table}
            WHERE
                id = ?
        SQL
        data.map { |datum| self.new(datum) }[0]
    end

    def self.all
        table = self.to_s.tableize
        data = QuestionsDatabase.instance.execute("SELECT * FROM #{table}")
        data.map { |datum| self.new(datum) }
      end
end
