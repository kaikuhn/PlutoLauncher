
using Sockets
using Pluto
using ArgParse
import Pkg

"""
    get_config(args)

Parse default values.

# ARGS:
- `dir`: 1st value
- `port`: 2nd value
"""
function get_config(args)

    s = ArgParse.ArgParseSettings(description = "Pluto Desktop Launcher")

    ArgParse.add_arg_table!(s,
        "dir", Dict(
            :help => "Directory for Notebooks",
            :arg_type => String,
            :default => joinpath(homedir(), "PlutoNotebooks")
        ),
        ["--url"], Dict(
            :help => "Server URL",
            :arg_type => String,
            :default => "127.0.0.1"
        ),
        ["--port", "-p"], Dict(
            :help => "Server Port",
            :arg_type => Int,
            :default => 1234
        ),
        ["--update", "-u"], Dict(
            :help => "Erzwinge ein Update der Pluto-Umgebung",
            :action => :store_true
        )
    )

    parsed_args = ArgParse.parse_args(args, s)

    # Update-Logik
    if parsed_args["update"]
        @info "Executing update ..."
        Pkg.update()
    end

    # Working dir
    dir = expanduser(parsed_args["dir"])
    mkpath(dir)
    cd(dir)

    # URL
    url = parsed_args["url"]

    # Port
    port = parsed_args["port"]
    while true
        if port>65535 error("Port $port reached the maximum value.") end
        try
            server = listen(IPv4(127,0,0,1),port)
            close(server)
            break
        catch
            @info "Port $port already in use. Take next one ..." 
            port += 1
        end
    end

    return dir, url, port
end

"""
    get_browser()

Returns best browser choice for Pluto.
"""
function get_browser()
    browsers = ["chromium", "google-chrome", "brave", "microsoft-edge", "microsoft-edge-stable"]

    path, browser = nothing, nothing

    # find installed browsers
    for b in browsers
        path = Sys.which(b)
        if !isnothing(path)
            browser = b
            break
        end
    end

    return browser, path
end

"""
    ensure_package(pkg_name::String, uuid::String)

Checks if package is already installed in the specific directory

# Arguments:
- `pkg_name::String`: name of the package
- `uuid::String`: UUID of the package
"""
function ensure_package(pkg_name::String, uuid::String)
    if !haskey(Pkg.dependencies(), Base.UUID(uuid))
        @info "Package $pkg_name missing. Installing ..."
        Pkg.add(pkg_name)
    end
    pkg_sym = Symbol(pkg_name)
    if !isdefined(Main, pkg_sym)
        Base.eval(Main, :(using $pkg_sym))
    end
end

"""
    pluto(port::Integer)

Starts the Pluto server if its not already running.
"""
function pluto(args)
    
    @info "Apply configuration ..."
    dir, url, port = get_config(args)
    browser, browser_path = get_browser()

    @info "Starting pluto server ..."
    pluto_server = @async Pluto.run(host=url, port=port, launch_browser=false)

    @info "Waiting for connection ..."
    for i in 1:60
        try
            connect(url, port)
            break
        catch
            sleep(0.5)

            if istaskfailed(pluto_server)
                error("Server error - Pluto server did not start!")
            elseif i>=60
                error("Timeout - could not connect to server!")
            end
        end
    end

    @info "Starting Browser ..."
    if !isnothing(browser)
        run(`$browser --app=http://$url:$port`)
    else

        @info "No compatible browser installed! Try starting Pluto uding Blink.jl ..."
        
        @info "Installing Blink.jl if necessary ..."
        ensure_package("Blink", "ad839575-38b3-5650-b840-f874b8c74a25")

        @info "Starting Window for Pluto ..."
        w = Base.invokelatest(Main.Blink.Window)
        Base.invokelatest(Main.Blink.loadurl, w, "http://$url:$port")

        # wait until window is closed
        while true
            try
                if !Base.invokelatest(Main.Blink.active, w) break end
            catch e
                break
            end
            sleep(1e0)
        end
    end

    # --- Block---
    
    @info "Fenster geschlossen. Beende Pluto..."
    exit(0)
end

if abspath(PROGRAM_FILE) == @__FILE__
    pluto(ARGS)
end
