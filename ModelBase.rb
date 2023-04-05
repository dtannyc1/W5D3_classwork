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

    def save
        all_vars = self.instance_variables # returns [:@id, :@fname, :@lname]
        method_names = all_vars.map do |var|  # removes @, converts to [:id, :fname, :lname]
            var.to_s[1..-1].to_sym
        end
        table = self.class.to_s.tableize

        if self.id
            set_string = ""
            method_names.each do |name|
                set_string += name.to_s + " = \"" + self.method(name).call.to_s + "\", " if name != :id
            end
            set_string = set_string[0...-2] # remove extra ", "

            QuestionsDatabase.instance.execute(<<-SQL, self.id)
                UPDATE
                    #{table}
                SET
                    #{set_string}
                WHERE
                    id = ?
            SQL
        else
            column_names = ""
            values = ""
            method_names.each do |name|
                column_names += name.to_s + ", " if name != :id
                values += "\"" + self.method(name).call.to_s + "\", " if name != :id
            end
            column_names = column_names[0...-2] # remove extra ", "
            values = values[0...-2] # remove extra ", "

            puts column_names
            puts values

            QuestionsDatabase.instance.execute(<<-SQL)
                INSERT INTO
                    #{table} (#{column_names})
                VALUES
                    (#{values})
            SQL
            self.id = QuestionsDatabase.instance.last_insert_row_id
        end
    end
end
