module ActiveRecordLite
  module Associatable
    def has_one_through(name, through_name, source_name)
      through_options = self.assoc_options[through_name]
      define_method(name) do
        # human belongs_to house
        source_options      = through_options.model_class.assoc_options[source_name]
        through_table       = through_options.table_name
        through_foreign_key = through_options.foreign_key
        through_primary_key = through_options.primary_key

        source_table        = source_options.table_name
        source_foreign_key  = source_options.foreign_key
        source_primary_key  = source_options.primary_key

        self_foreign_key    =
        results = DBConnection.execute(<<-SQL, self.send(through_foreign_key))
          SELECT
            #{source_table}.*
          FROM
            #{through_table}
          JOIN
            #{source_table}
          ON
            #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
          WHERE
            #{through_table}.#{through_primary_key} = ?
        SQL
        source_options.model_class.parse_all(results).first
      end
    end
  end
end
