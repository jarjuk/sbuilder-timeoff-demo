
require "sqlite3"


module Sqlite3Manager
  
  # @!attribute [Sqlite3] database  
  attr_accessor :database

  # ------------------------------------------------------------------
  # @!group Start with database

  def create_database( dbFile )
    self.database = SQLite3::Database.new dbFile
  end
  
  def open_database( dbFile )
    self.database = SQLite3::Database.open dbFile
  end

  # @!endgroup

  

  # ------------------------------------------------------------------
  # @!group SQL-operations
  
  def create_table( tableName, schema )
    
    cols = schema.reduce( "" ) do |c,(k,v)|
      c +=  c == "" ? "" : ", "
      c+= "#{k}  varchar(30)" 
      c
    end
    database.execute( "create table #{tableName} ( #{cols} )")
  end
  
  def delete_table( tableName )
    database.execute "delete from #{tableName}"
  end

  # @param tableName [String] name of table 
  #      
  # @param schemaColValues [Hash] hash (key value pair) to insert
  #      
  #
  def insert_table( tableName, schemaColValues )
    columns = getColumnNames( schemaColValues )
    values = ["?"] * schemaColValues.keys.length

    database.execute( "INSERT INTO #{tableName} ( #{columns} ) VALUES ( #{values.join(',')} )",
                      schemaColValues.values )
  end

  # @param schemaCols [String|Hash] columns to select, String use
  #         fixed, Hash select using keys
  #      
  #
  def select_from_table( tableName, schemaCols, where=nil, &blk )
    columns = schemaCols.is_a?(String) ? schemaCols :  getColumnNames( schemaCols )
    
    whereStr = if where.nil? then
                 ""
               elsif where.is_a?(String) then
                 " WHERE #{where}"
               elsif where.is_a?(Hash) then
                 where.inject("") do |s,(col,val)|
                   s +=  s == "" ? " WHERE " : " AND "
                   s += " #{col} = '#{val}'"
                   s
                 end
               else 
                 raise "Supports only String or Hash in where"
               end
    ret = []
    database.execute( "select #{columns} from #{tableName} #{whereStr}").each do |row|

      # convert array to a hash using cols keys 
      h={}
      schemaCols.keys.each_with_index do |key,i|
        h[key] = row[i]
      end
      ret << h
      yield h if blk
    end
    ret
  end
  

  # @!endgroup

  # ------------------------------------------------------------------
  # @!group Short cuts


  # @return [Boolean] true if exists, false if not exists 
  def table_exists( tableName )
    itExits = false
    begin
      select_from_table( tableName, "1", nil )
      itExits = true
    rescue SQLite3::SQLException => e
      # assume expcetion if it does not exist
    end
    itExits
  end

  # @!endgroup

  # ------------------------------------------------------------------
  # @!group Stop processing

  def close_database( db=nil )
    database.close unless db.nil?
    self.database
  end


  def delete_database( dbFile )
    File.delete( dbFile )  if File.exists?( dbFile )
  end
  
  
  # @!endgroup

  # ------------------------------------------------------------------
  # @!group Private helpers

  private

  # @param schemaCols [Hash] hash with keys as column names
  #      
  #
  def getColumnNames( schemaCols  )
    columns = "#{schemaCols.keys.join(',')}"  
  end

  
  # @!endgroup

end # module Sqlite3Manager
