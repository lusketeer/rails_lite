module ActiveRecordLite
  module Searchable
    def where(params)
      cols = params.keys.map { |col| "#{col} = ?" }.join(" AND ")
      results = DBConnection.execute(<<-SQL, params.values)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          #{cols}
      SQL
      results.map do |result|
        self.new(result)
      end
    end
  end
end
