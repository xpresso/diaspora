#!/usr/bin/ruby
#
# Initiate the public (i. e., assets) directory
#
#
require 'optparse'

Dir.chdir( File.expand_path( File.dirname( __FILE__) + "/.."))

def is_newer( derived, template)
     return false unless File.exists?( derived)
     r = File.new(derived).stat <=> File.new(template).stat
     return ( r == 1 )
end

def get_last_file
    # Get last updated file, returns a dummy if none found.
    
    if File.exists?( 'config/gitversion')
        return 'config/gitversion'
    elsif  File.exists?( '.git' )
        return `git log --name-only -1 | tail -1`.chomp
    else
        $stderr.puts "Warning: can't find out last file updated"
        $stderr.puts "   - startup will take some extra time."
        FileUils.touch 'tmp/last_run'
        return 'tmp/last_run'
    end
end

force_opt = false
verbose_opt = false
optparse = OptionParser.new do|opts|
    opts.banner = 'Usage: public_setup [options]'
    opts.on( '-f', '--force', 'Force rebuild' ) do
        force_opt  = true
    end
    opts.on( '-v', '--verbose', 'Print some messages' ) do
        verbose_opt  = true
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end

optparse.parse!  

last_file = get_last_file

if force_opt or not is_newer( 'public/source.tar.gz', last_file)
    puts 'Re-building AGPL compliance source tarball' if verbose_opt
    branch = `git branch | awk '/^[*]/ {print $2}'`.chomp
    system( "tar czf public/source.tar.gz "  + 
                "$(git ls-tree -r #{branch}  | awk '{print $4}')")
end

if force_opt or not is_newer( 'public/stylesheets/application.css', 
                               last_file )
    puts "Making first-time server initializations" if verbose_opt

    require 'net/http'
    require 'config/environment.rb'
    require 'jammit'

    if File.exists?( 'public/stylesheets/application.css')
        File.delete( 'public/stylesheets/application.css')
    end
    uri = AppConfig[:pod_uri].normalize
    system( "bundle exec thin -d -P tmp/server.pid -p #{uri.port} start")
    begin
        Timeout::timeout(60) {
            begin
                res = Net::HTTP.start( uri.host, uri.port) {|http|
                    http.get( "/" + uri.path)
                }
            rescue => e
                sleep( 2 ) 
            end while res.nil?
        }
        Jammit.package!
    rescue => e
        $stderr.puts "Cannot start web server" + e.inspect
    ensure
        if File.exists?( 'tmp/server.pid' )
            pid = IO.read( 'tmp/server.pid').chomp || "0"
            system( "kill #{pid}") unless pid == "0"
        end
    end
end

if force_opt or not is_newer( 'public/.timestamp', 
                              'config/app_config.yml')
    puts "Refreshing data depending on app_config.yml" if verbose_opt

    require "config/environment.rb"
    require 'rake'

    # Set up sub-uri symlink for assets.
    system( "find public -maxdepth 1 -type l -delete")
    sub_uri=AppConfig[:pod_uri].path.to_s
    sub_uri.slice!(0)
    unless  sub_uri.nil? or sub_uri.empty? or sub_uri == "/" 
        puts "Creating sub-uri asset symlink: " + sub_uri if verbose_opt
        Dir.chdir( "public" )
        File.symlink( ".", sub_uri)
        Dir.chdir( ".." )
    end 

    # Create static public/well-known/host-meta.
    puts "Building host-meta" if verbose_opt
    Dir.mkdir( 'public/host-meta') unless File.exists?('public/host-meta')
    load File.join( RAILS_ROOT, 'lib', 'tasks', 'host_meta.rake')
    Rake::Task["host_meta"].invoke( 'public/well-known/host-meta')

    FileUtils.touch( 'public/.timestamp')
end
