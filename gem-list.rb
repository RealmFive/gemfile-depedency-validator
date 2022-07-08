class Dependencies
    class << self
        def list_of_dependencies()
            f=File.open('../periodic-pigeon/Gemfile')
            list= []
            f.each do |line|
                if line.index("gem") == 0
                    list << line.split[1].gsub("'", "").gsub(",","")
                end
            end
            f.close
            list
        end

        def reset(dependencies)
            Dir.chdir("../periodic-pigeon")
            `git reset --hard && bundle install`
        end

        def test_method(dependencies)
            Dir.chdir("../periodic-pigeon")
            output =`git status --porcelain --untracked-files=no`

            if output.empty? ==true
                dependencies.select do |dependency|
                    puts "removing #{dependency}"
                    `bundle remove #{dependency}`
                    puts "running tests"
                    `rails test`
                    success= ($?.exitstatus == 0)
                    puts "reseting"
                    `git reset --hard && bundle install`
                    success
                end
            else
                puts "File was modified after previous commit"
                puts output
            end
            
        end
    end
end

dependencies =Dependencies.list_of_dependencies()
unnecessary =Dependencies.test_method(dependencies)
puts "These dependencies are not necessary"
unnecessary.each {|u| puts "- #{u}"}

# Dependencies.reset(dependencies)