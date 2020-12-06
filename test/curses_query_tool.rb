require 'curses'
require 'net/http'
require 'uri'
require 'json'
require 'byebug'

$baseurl = 'http://localhost:3000/'

#TODO: Generate swagger docs: Got swagger running, but some issues with swagger gem to investigate

Curses.init_screen
begin
  class Menu
    def Menu.start(choices)
      menu = Menu.new(choices)
      return menu.menu_loop
    end
  
    def initialize(choices)
      @choices = choices
      @num_choices = choices.length
      @index = 0
    end
  
    def menu_loop
      while true
        display
        input = Curses.getch
        case input
        when "w"
          @index -=1
        when "s"
          @index +=1
        when " "
          return @choices[@index],@index
        end
  
        if @index<0 then
          @index = 0
        end
        if @index>@num_choices-1 then
          @index = @num_choices-1
        end
      end
    end
  
    def display
      Curses.clear
      @num_choices.times do |i|
        Curses.setpos(i,5)
        Curses.addstr("#{@choices[i]}")
      end
  
      Curses.setpos(@index,0)
      Curses.addstr("-->")
  
      Curses.refresh
    end
  end

  def authenticate(username)
    url = $baseurl + 'authenticate'
    uri = URI.parse(url)
  
    case username
    when "markw"
      email = "markw@yova.ch"
      password = "foo"
    when "johns"
      email = "johns@yova.ch"
      password = "bar"
    when "bgates"
      email = "mrgates@microsoft.com"
      password = "password1"
    when "mzuckerberg"
      email = "zucker@facebook.com"
      password = "password2"
    when "dfuld"
      email = "gorilla@lehman.com"
      password = "password3"
    when "hacker"
      email = "l337@sup3rl33t.com"
      password = "1qaz2wsx"
    end
    params = {'email' => email,'password' => password}
  
    res = Net::HTTP.post_form(uri, params)
    if res.code=="200"
      reshash = JSON.parse(res.body)
      auth_token = reshash["auth_token"]
    else
      auth_token = nil
    end
    auth_token
  end

  class Portfolios
    def initialize(auth_token)
      @auth_token = auth_token
    end

    def index
      url = $baseurl + 'client_portfolios'
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
      if res.code=="200"
        portfolios = JSON.load(res.body)
      else
        portfolios = nil
      end
    end

    def content(id)
      url = $baseurl + "client_portfolios/#{id}/content.json"
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

    def valuation(id)
      url = $baseurl + "client_portfolios/#{id}/valuation.json"
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

    def return(id)
      url = $baseurl + "client_portfolios/#{id}/return.json"
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end


  end

  class ClientNotifications
    def initialize(auth_token)
      @auth_token = auth_token
    end

    def index
      url = $baseurl + 'client_notifications'
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
      if res.code=="200"
        notifications = JSON.load(res.body)
      else
        notifications = nil
      end
    end

    def show(id)
      url = $baseurl + "client_notifications/#{id}.json"
      uri = URI.parse(url)

      req = Net::HTTP::Post.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

  end

  class Notifications
    def initialize(auth_token)
      @auth_token = auth_token
    end

    def index
      url = $baseurl + 'notifications'
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
      if res.code=="200"
        notifications = JSON.load(res.body)
      else
        notifications = nil
      end
    end

    def show(id)
      url = $baseurl + "notifications/#{id}.json"
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

    def delete(id)
      url = $baseurl + "notifications/#{id}.json"
      uri = URI.parse(url)

      req = Net::HTTP::Delete.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

    def update(id)
      Curses.clear
      Curses.setpos(0,0)
      Curses.addstr("Update notification #{id}: ")
      Curses.refresh

      message = Curses.getstr
      url = $baseurl + "notifications/#{id}.json"
      uri = URI.parse(url)
      req = Net::HTTP::Put.new(uri)
      req.set_form_data({'message'=>message})
      req['Authorization'] = @auth_token
      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
    end

    def create()
      Curses.clear
      Curses.setpos(0,0)
      Curses.addstr("Create notification: ")
      Curses.refresh
      
      message = Curses.getstr
      url = $baseurl + "notifications.json"
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data({'message'=>message})
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

    end

  end

  class Clients
    def initialize(auth_token)
      @auth_token = auth_token
    end

    def index
      url = $baseurl + 'clients'
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
      if res.code=="200"
        clients = JSON.load(res.body)
      else
        clients = nil
      end
    end
  end

  class Assignments
    def initialize(auth_token, notification_id)
      @auth_token = auth_token
      @notification_id = notification_id
    end

    def index
      url = $baseurl + 'notifications/' + @notification_id.to_s + '/assignments'
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
      if res.code=="200"
        clients = JSON.load(res.body)
      else
        clients = nil
      end
    end

    def create()
      #Get list of clients...
      clients = Clients.new(@auth_token)
      cli = clients.index

      cl = cli.map {|cli_i| cli_i['username']}
      sel,id = Menu.start(cl);

      url = $baseurl + "notifications/" + @notification_id.to_s + "/assignments.json"
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data({'client'=>sel})
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

    end

    def show(id)
      url = $baseurl + "assignments/#{id}.json"
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

    def delete(id)
      url = $baseurl + "assignments/#{id}.json"
      uri = URI.parse(url)

      req = Net::HTTP::Delete.new(uri)
      req['Authorization'] = @auth_token

      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

      notifications = JSON.load(res.body)
    end

    def update(id)
      #Get list of clients...
      clients = Clients.new(@auth_token)
      cli = clients.index

      cl = cli.map {|cli_i| cli_i['username']}
      sel,id = Menu.start(cl);

      url = $baseurl + "assignments/#{id}.json"
      uri = URI.parse(url)
      req = Net::HTTP::Put.new(uri)
      req.set_form_data({'client'=>sel})
      req['Authorization'] = @auth_token
      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
    end

  end

  def msg(text,y=Curses.lines/2,x=Curses.cols/2)
    Curses.clear
    Curses.setpos(y,x)
    Curses.addstr(text)
    Curses.refresh
    Curses.getch
  end
  
  def mainloop

    while true
      user,pos = Menu.start( ["bgates","dfuld","mzuckerberg","johns","markw","hacker"])
  
      auth_token = authenticate(user)
      if not auth_token
        msg('DENIED')
        next
      end

      type,pos = Menu.start( ["Admin","Portfolio","Notification"])
      case type
        when "Admin"
          notifications = Notifications.new(auth_token)
          notif = notifications.index
          if notif
            ids = []
            notif.each do |section|
              ids.append(section["id"])
            end
            id,pos = Menu.start(["Create"]+ids)
            if pos==0
              notifications.create()
              next
            end
            action,pos = Menu.start(["Show:#{id}","Update:#{id}","Delete:#{id}","Assign:#{id}"])
            case pos
            when 0
              notif = notifications.show(id)
              msg(JSON.pretty_generate(notif),0,0)
            when 1
              notifications.update(id)
            when 2
              notif = notifications.delete(id)
              msg('DELETED')
            when 3
              #Get assignments
              assignments = Assignments.new(auth_token, id)
              asn = assignments.index
              assignment_ids = []
              asn.each do |section|
                assignment_ids.append(section["id"])
              end
              id,pos = Menu.start(["Assign"]+assignment_ids)
              if pos==0
                assignments.create()
                next
              end
              action,pos = Menu.start(["Show:#{id}","Update:#{id}","Delete:#{id}"])
              case pos
              when 0
                notif = assignments.show(id)
                msg(JSON.pretty_generate(notif),0,0)
              when 1
                assignments.update(id)
              when 2
                notif = assignments.delete(id)
                msg('DELETED')
              end
              
              #set the assignments - or add/delete them??
            end
          else
            msg('DENIED')
          end

        when "Portfolio"
          #get portfolios
          portfolios = Portfolios.new(auth_token)
          port = portfolios.index
          if port
            names = []
            port.each do |section|
              names.append("#{section["id"]}:#{section["name"]}")
            end
            name,pos = Menu.start(names)
            id = port[pos]["id"]
            action,pos = Menu.start(["Show:#{id}","Valuation:#{id}","Return:#{id}"])
            case pos
            when 0
              notif = portfolios.content(id)
              msg(JSON.pretty_generate(notif),0,0)
            when 1
              notif = portfolios.valuation(id)
              msg(JSON.pretty_generate(notif),0,0)
            when 2
              notif = portfolios.return(id)
              msg(JSON.pretty_generate(notif),0,0)
            end
          else
            msg('DENIED')
          end
        when "Notification"
          notifications = ClientNotifications.new(auth_token)
          note = notifications.index
          if !note
            msg('DENIED')
          elsif !note.empty?
            ids = note.map {|nt| nt['id']}
            sel,id = Menu.start(ids)
            notif = notifications.show(sel)
            msg(JSON.pretty_generate(notif),0,0)
          else
            msg("No notifications")
          end
      end
    end
  end

  mainloop

ensure
  Curses.close_screen
end


  #Curses.clear
  #Curses.setpos(0,0)
  #Curses.addstr(choice)
  #Curses.refresh
  #
  #  Curses.close_screen
  #  byebug
  
