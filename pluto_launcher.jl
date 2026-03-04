
using Sockets
import Pkg

# check, if package is installed
"""
    ensure_package(pkg_name::String, uuid::String)

Checks if package is already installed in the specific directory

# Arguments:
- `pkg_name::String`: name of the package
- `uuid::String`: UUID of the package
"""
function ensure_package(pkg_name::String, uuid::String)
    if !haskey(Pkg.dependencies(), Base.UUID(uuid))
        @info "Paket $pkg_name fehlt. Installiere..."
        Pkg.add(pkg_name)
    end
end

"""
    get_config(args)

Parse default values.

# ARGS:
- `dir`: 1st value
- `port`: 2nd value
"""
function get_config(args)
    
    # getting ArgParse.jl
    @info "Installing ArgParse.jl if necessary ..."
    ensure_package("ArgParse", "c7e460c6-2fb9-53a9-8c5b-16f535851c63")
    Base.require(Main, :ArgParse)
    ArgParse = Main.ArgParse

    s = ArgParse.ArgParseSettings(description = "Pluto Desktop Launcher")

    ArgParse.@add_arg_table! s begin
        "dir"
            help = "Directory for Notebooks"
            arg_type = String
            default = joinpath(homedir(), "PlutoNotebooks")
        "--url"
            help = "Server URL"
            arg_type = String
            default = "127.0.0.1"
        "--port", "-p"
            help = "Server Port"
            arg_type = Int
            default = 1234
        "--update", "-u"
            help = "Erzwinge ein Update der Pluto-Umgebung"
            action = :store_true
    end

    parsed_args = ArgParse.parse_args(args, s)

    # Update-Logik
    if parsed_args["update"]
        @info "Manuelles Update wird ausgeführt..."
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
    pluto(port::Integer)

Starts the Pluto server if its not already running.
"""
function pluto(args)

    @info "Activating environment ..."
    pluto_launcher_env_dir = joinpath(homedir(), ".pluto_launcher_env")
    mkpath(pluto_launcher_env_dir)
    Pkg.activate(pluto_launcher_env_dir)

    @info "Installing Pluto.jl if necessary ..."
    ensure_package("Pluto", "c3e58a33-4697-519d-905e-579a4ad08bb4")
    Base.require(Main, :Pluto)
    Pluto = Main.Pluto
    
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
        # install Blink.jl, if necessary
        ensure_package("Blink", "ad839575-38b3-5650-b840-f874b8c74a25")
        Base.require(Main, :Blink)
        Blink = Main.Blink

        @info "Starting Window for Pluto ..."
        w = Blink.Window()
        Blink.loadurl(w, "http://$url:$port")

        # wait until window is closed
        while true
            try
                if !Blink.active(w) break end
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
