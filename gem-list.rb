#This gives out the list of dependencies that are not necessary and prints all of the in the 'dependency_status.json' file
#by specifying if they are required or not. It firsts checks if there was any gems that were run in the past (in the json file) and
#then continues from there.

require 'json'

class Dependencies
    class << self
        def list_of_dependencies()
            File.open('../periodic-pigeon/Gemfile') do |file|
                file.each_line
                    .select { |line| line.start_with?("gem") }
                    .map { |line| line.split[1].tr("',", "") }
            end
        end

        def reset(dependencies)
            Dir.chdir("../periodic-pigeon")
            `git reset --hard && bundle install`
        end

        def load_statuses
            if File.exists?('dependency_status.json')
                json =File.read('dependency_status.json')
                JSON.parse(json)
            else
                {}
            end
        end

        def unload_statuses(statuses)
            json= JSON.unparse(statuses) #generate json string from the hash
            File.write('dependency_status.json', json) # hashes to file
        end

        def test_method(dependencies)
            Dir.chdir("../periodic-pigeon")
            output =`git status --porcelain --untracked-files=no`
            unless output.empty? 
                puts "File was modified after previous commit"
                return
            end
            statuses = load_statuses
                
            dependencies.each do |dependency|
                if statuses.key?(dependency)
                    puts "skipping #{dependency}"
                    next
                end

                puts "removing #{dependency}"
                `bundle remove #{dependency}`
                `bundle clean --force`  #This command cleans up all unnecessary dependencies!
                puts "running tests"
                `rails test`
                statuses[dependency]=($?.exitstatus != 0) #false means safe to go
                unload_statuses(statuses)
                puts "reseting"
                `git reset --hard && bundle install`
            end
            statuses.select{|k, v| !v}.keys
        end
    end
end

dependencies =Dependencies.list_of_dependencies()
unnecessary =Dependencies.test_method(dependencies)


puts "These dependencies are not necessary"
unnecessary.each {|u| puts "- #{u}"}

# Dependencies.reset(dependencies)
