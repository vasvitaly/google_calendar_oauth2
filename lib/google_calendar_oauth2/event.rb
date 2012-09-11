module GoogleCalendar
  class Event
    attr_accessor :id, :summary, :calendar_id, :start_time, :end_time, :sequence, :etag, :status, :html_link, :created_at, :updated_at

    extend Connection

    def initialize(attrs)
      # dt_format = '%Y-%m-%dT%H:%M:%S%z'
      attrs['start'] ||= {}
      attrs['end'] ||= {}
      attrs['start']['dateTime'] ||= Date.today.to_time.utc
      attrs['end']['dateTime'] ||= Date.today.to_time.utc
      @id = attrs['id']
      @etag = attrs['etag']
      @summary = attrs['summary']
      @status = attrs['status']
      @html_link = attrs['htmlLink']
      @created_at = attrs['created'].is_a?(String) ? DateTime.parse(attrs['created']).utc : attrs['created']
      @updated_at = attrs['updated'].is_a?(String) ? DateTime.parse(attrs['updated']).utc : attrs['updated']
      @calendar_id = attrs['calendar_id']
      @sequence = attrs['sequence']
      @start_time = attrs['start']['dateTime'].is_a?(String) ? DateTime.parse(attrs['start']['dateTime']).utc : attrs['start']['dateTime']
      @end_time = attrs['end']['dateTime'].is_a?(String) ? DateTime.parse(attrs['end']['dateTime']).utc : attrs['end']['dateTime']
    end

    alias attributes= initialize

    def to_s
    "#&lt;Event id: #{self.id}, summary: #{self.summary}, start_time: #{self.start_time}, end_time: #{self.end_time}, calendar_id: #{self.calendar_id}, sequence: #{self.sequence}, etag: #{self.etag}, status: #{self.status}, html_link: #{self.html_link}, created_at: #{self.created_at}, updated_at: #{self.updated_at}&gt;"
    end

    def attributes
      {
        :id => id,
        :etag => etag,
        :summary => summary,
        :status => status,
        :html_link => html_link,
        :created_at => created_at,
        :updated_at => updated_at,
        :calendar_id => calendar_id,
        :sequence => sequence,
        :start => {
          :dateTime => start_time.to_time
        },
        :end => { 
          :dateTime => end_time.to_time
        }
      }
    end

    def self.list(calendar_id, options={})
      options = convert_dates_in_options(options)

      list = connection.execute(:api_method => client.events.list, :parameters => options.merge({ 'calendarId' => calendar_id }))
      events = []
      list.data.items.each do |event|
        events << new(event)
      end
      events
    end

    def self.find_by_name(calendar_id, query)
      list(calendar_id).each do |event|
        if event.summary == query
          return @event = new(event.merge({ 'calendar_id' => calendar_id }))
        end
      end
      @event
    end

    def self.find_by_id(calendar_id, id)
      event = connection.execute(
        :api_method => client.events.get, 
        :parameters => { 
          'calendarId' => calendar_id, 
          'eventId' => id 
        }
      )
      new event.data.to_hash.merge 'calendar_id' => calendar_id
    end

    def self.create(calendar_id, attrs)
      attrs = convert_dates_in_options(attrs)
      new connection.execute(
        :api_method => client.events.insert, 
        :parameters => { 'calendarId' => calendar_id }, 
        :body => [attrs.to_json],  #JSON.dump()
        :headers => {'Content-Type' => 'application/json'}
      ).data.to_hash.merge 'calendar_id' => calendar_id
    end

    def update(attrs = {})
      self.sequence = self.sequence.nil? ? 1 : self.sequence + 1
      attrs = self.attributes.merge(attrs)
      attrs = self.class.convert_dates_in_options(attrs)
      params = {:api_method => Event.client.events.update, 
        :parameters => { 
          'calendarId' => self.calendar_id, 
          'eventId' => self.id 
        }, 
        :body => [attrs.to_json], 
        :headers => {'Content-Type' => 'application/json'}
      }
      result = Event.connection.execute( params ).data.to_hash.merge('calendar_id' => self.calendar_id)
      self.attributes = result
      self
    end
  
    def self.delete(calendar_id, event_id)
      connection.execute(
        :api_method => client.events.delete, 
        :parameters => { 
          'calendarId' => calendar_id, 
          'eventId' => event_id 
        }
      )
    end

    def self.convert_dates_in_options(options)
      options.each_pair{|k,v| 
        if v.is_a?(Time) || v.is_a?(DateTime) || v.is_a?(Date) 
          options[k] = v.utc.strftime('%Y-%m-%dT%H:%M:%S-0000') 
        end
        if v.is_a? Hash
          options[k] = convert_dates_in_options(v)
        end
      }
      options
    end
  end
end