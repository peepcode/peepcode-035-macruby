class TRConnectionDelegate

  def initialize(parent, &block)
    @parent = parent
    @block = block
  end

  def connectionDidFinishLoading(connection)
    doc = NSXMLDocument.alloc.initWithData(@receivedData,
                                           options:NSXMLDocumentValidate,
                                           error:nil)

    if doc
      statuses = doc.nodesForXPath("*/status|status", error:nil)
      if statuses and !statuses.empty?
        tweets = statuses.map do |s|
          {
            :user => s.nodesForXPath('user/name', error:nil).first.stringValue,
            :tweet => s.nodesForXPath('text', error:nil).first.stringValue,
            :profile_image_url => s.nodesForXPath('user/profile_image_url', error:nil).first.stringValue,
            :url => s.nodesForXPath('user/url', error:nil).first.stringValue,
            :created_at => s.nodesForXPath('created_at', error:nil).first.stringValue,
          }
        end
        @block.call(tweets)
      end
    else
      @block.call("Invalid response")
    end
  end

  def connection(connection, didReceiveResponse:response)
    case response.statusCode
    when 401
      @block.call("Invalid username and password")
    when (400..500)
      @block.call("Unable to complete your request")
    end
  end

  def connection(connection, didReceiveData:data)
    @receivedData ||= NSMutableData.new
    @receivedData.appendData(data)
  end

  def connection(conn, didFailWithError:error)
    @parent.send_button.enabled = true
    @parent.status_label.stringValue = "Error sending update"
  end
end
