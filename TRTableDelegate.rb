
class TRTableDelegate

  attr_accessor :parent
  
  def numberOfRowsInTableView(tableView)
    parent.updates.count
  end
  
  def tableView(tableView, objectValueForTableColumn:column, row:row)
    NSLog("Asked for row: #{row} column: #{column}")
    if row < parent.updates.length
      return parent.updates[row].valueForKey(column.identifier)
    end
    nil
  end

end
