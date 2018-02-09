
# Expect 'asIs' to include 'toBe'
def chk_db_table_included( asIs:, toBe:, keyLambda:, comment: "" )

  comment = comment + " " if comment.length
  
  support_debug "#{comment}chk_db_table_included: asIs=#{asIs}"
  support_debug "#{comment}chk_db_table_included: toBe=#{toBe}"
  
  expect( asIs ).to be_a( Array)
  expect( toBe ).to be_a( Array)
  expect( asIs.length ).to eql( toBe.length )
  # expect( asIs.elg )
  toBe.each do |toBeRow|
    # expect( userToBe["email"] ).not_to eql nil
    asIsRows = asIs.select{ |row| keyLambda[row, toBeRow] }
    expect( asIsRows.length ).to eql 1
    asIsRow = asIsRows.first
    expect( asIsRow ).to include( toBeRow )
  end
  
end
