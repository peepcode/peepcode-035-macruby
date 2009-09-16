require 'base64'
require 'cgi'

class TwittRbDelegate

  attr_accessor :credentials_window, :main_window
  attr_accessor :username_field, :password_field
  attr_accessor :username, :password, :updates
  attr_accessor :table_view, :status_label
  attr_accessor :reload_button
  attr_accessor :tweet_field, :send_button
  
  def applicationDidFinishLaunching(notification)
    NSApp.beginSheet(credentials_window,
                    modalForWindow:main_window,
                    modalDelegate:nil,
                    didEndSelector:nil,
                    contextInfo:nil)
  end
  
  def initialize
    @updates = []
  end
  
  def submitCredentials(sender)
    self.username = username_field.stringValue
    self.password = password_field.stringValue
    NSApp.endSheet(credentials_window)
    credentials_window.orderOut(sender)
    NSLog "I have #{username} as a username"
    NSLog "I have a password length of #{password.length}"
    retrieveTweets(sender)
  end
  
  def retrieveTweets(sender)
    url = NSURL.URLWithString("https://twitter.com/statuses/friends_timeline.xml")
    request = NSMutableURLRequest.requestWithURL(url)
    auth_token = Base64.encode64("#{username}:#{password}").strip
    request.setValue("Basic #{auth_token}",
                     forHTTPHeaderField:"Authorization")

    delegate = TRConnectionDelegate.new(self) do |response|
      if Array === response
        self.updates = response
        self.table_view.reloadData
        self.reload_button.enabled = true
        self.status_label.stringValue = "Tweets updated"
      else
        self.send_button.enabled = true
        self.status_label.stringValue = response
      end
    end

    NSURLConnection.connectionWithRequest(request, delegate:delegate)

    self.reload_button.enabled = false;
    self.status_label.stringValue = "Loading..."
  end
  
  def hideCredentials(sender)
    NSLog "Cancelled twitter credentials"
    NSApp.endSheet(credentials_window)
    credentials_window.orderOut(sender)
  end

  def postTweet(sender)
    url = NSURL.URLWithString("http://twitter.com/statuses/update.xml")
    request = NSMutableURLRequest.requestWithURL(url)
    request.HTTPMethod = "POST"
    auth_token = Base64.encode64("#{username}:#{password}").strip
    request.setValue("Basic #{auth_token}",
                     forHTTPHeaderField:"Authorization")

    body = "status=#{CGI.escape(self.tweet_field.stringValue)}"
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)

    delegate = TRConnectionDelegate.new(self) do |response|
      if Array === response
        NSLog "Got an update: #{response.inspect}"
        self.updates = response.concat(updates)
        self.table_view.reloadData
        self.send_button.enabled = true
        self.tweet_field.stringValue = ""
        self.status_label.stringValue = "Status Updated"
      else
        self.send_button.enabled = true
        self.status_label.stringValue = "Invalid response"
      end
    end

    NSURLConnection.connectionWithRequest(request, delegate:delegate)

    self.send_button.enabled = false;
    self.status_label.stringValue = "Updating Status..."
  end
 
end
