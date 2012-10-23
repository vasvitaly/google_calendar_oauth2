module GoogleCalendar
  class Calendar

    extend Connection

    def self.list
      list = connection.execute(client.calendar_list.list)
      list.data.items
    end

    def self.find(query)
      rq = Regexp.new query
      list.each do |cal|
        return @cal = cal if cal.id == query || cal.summary == query || (cal.summary =~ rq)
      end
      @cal
    end

    def self.create(attrs)
      connection.execute(:api_method => client.calendars.insert, :body => [JSON.dump(attrs)], :headers => {'Content-Type' => 'application/json'})
    end
  end
end