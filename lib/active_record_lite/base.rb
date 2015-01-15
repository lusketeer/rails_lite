module ActiveRecordLite
  # NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
  # of this project. It was only a warm up.

  class Base
    extend Searchable
    extend Associatable

    def self.my_attr_accessor(*names)
      names.each do |name|
        define_method(name) do
          self.instance_variable_get("@#{name}")
        end
        define_method("#{name}=") do |arg|
          self.instance_variable_set("@#{name}", arg)
        end
      end
    end

    def self.columns
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      result.first.map do |col|
        col.to_sym
      end
    end

    def self.finalize!
      self.columns.map do |col|
        # getter for column
        define_method(col) do
          self.attributes[col]
        end
        # setter for column
        define_method("#{col}=") do |arg|
          self.attributes[col] = arg
        end
      end
    end

    def self.table_name=(table_name)
      @table_name = table_name
    end

    def self.table_name
      @table_name || self.to_s.tableize
    end

    def self.all
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      self.parse_all(result.drop(1))
    end

    def self.parse_all(results)
      results.map do |result|
        self.new(result)
      end
    end

    def self.find(id)
      result = DBConnection.execute2(<<-SQL, id)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          id = ?
      SQL
      result.count != 1 ? self.new(result.last) : nil
    end

    def initialize(params = {})
      params.each do |attr_name, value|
        raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      end
    end

    def attributes
      @attributes ||= {}
    end

    def attribute_values
      attributes.values
    end

    def insert
      col_names = attributes.keys
      question_marks = ("?" * (col_names.count)).split("").join(", ")
      task = DBConnection.execute(<<-SQL, attribute_values)
        INSERT INTO
          #{self.class.table_name}
        (#{col_names.join(", ")})
          VALUES
        (#{question_marks})
      SQL
      self.id = DBConnection.last_insert_row_id if task
    end

    def update
      cols = attributes.map { |col, value| "#{col} = ?" }.join(", ")
      task = DBConnection.execute(<<-SQL, attribute_values)
        UPDATE
          #{self.class.table_name}
        SET
          #{cols}
        WHERE
          id = #{self.id}
      SQL
    end

    def save
      return self.insert if self.id.nil?
      self.update
    end
  end

end
