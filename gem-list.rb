class Dependencies
    class << self
        def read_file()
            f=File.open('../periodic-pigeon/Gemfile')
            list= []
            f.each do |line|
                if line.index("gem") == 0
                    # puts line
                    #list= %w line.split[1]
                    list << line.split[1].gsub("'", "").gsub(",","")
                    pp list
                end
            end
            f.close
        end

        def collection
            client[:events]
        end

        private

        def client
            return @client if defined?(@client)

            @client = Mongo::Client.new(["10.10.1.198:27017"], database: "deviceEventService", user: "alisson.ntwali", password: "CU6APrLEqTtj")
        end
    end
end

Dependencies.read_file()