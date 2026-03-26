
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
        "pos_dof", Dict(
            :help => "Directory or File of Notebook to open (positional)",
            :required => false
        ),
        ["--dof", "-d"], Dict(
            :help => "Directory or File of Notebook to open (flag)",
            :arg_type => String,
            :default => joinpath(homedir(), "PlutoNotebooks")
        ),
        ["--env_dir"], Dict(
            :help => "Directory for the Julia environment and Browser Profiles",
            :arg_type => String,
            :default => joinpath(homedir(), ".pluto_launcher_env")
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
            :help => "Update the Pluto environment",
            :action => :store_true
        )
    )

    parsed_args = ArgParse.parse_args(args, s)

    # Update-Logik
    if parsed_args["update"]
        @info "Executing update ..."
        Pkg.update()
        @info "Update finished ..."
        exit(0)
    else
        @info "No update ..."
    end
    
    # URL
    url = parsed_args["url"]
    @info "URL: $url"

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
        @info "PORT: $port"
    end

    # Notebook dir or file is dir
    raw_dof = isnothing(parsed_args["pos_dof"]) ? parsed_args["dof"] : parsed_args["pos_dof"]
    dof = expanduser(raw_dof)
    @info "WORKING_DIR: $dof"
    if isdir(dof)
        mkpath(dof)
    end
    
    # Browser profile dir in env_dir
    bp_dir = joinpath(parsed_args["env_dir"], "browser_profile", "$port")
    mkpath(bp_dir)

    return bp_dir, dof, url, port
end

"""
    get_browser()

Returns best browser choice for Pluto.
"""
function get_browser()
    browsers = [
        "chromium-browser", 
        "google-chrome", 
        "brave", 
        "microsoft-edge", 
        "microsoft-edge-stable"
    ]

    path, browser = nothing, nothing

    # find installed browsers
    for b in browsers
        path = Sys.which(b)
        if !isnothing(path)
            browser = b
            break
        end
    end

    # check selection
    if !isnothing(browser)
        @info "Found Browser: $browser"
    else
        @info "No compatible brouser found! Using Electron.jl ..."
    end

    return browser, path
end

"""
    open_browser(browser, bp_dir, url, port)

Opens Pluto in the selected browser in app-mode.
"""
function open_browser(browser, bp_dir, url, port)
    browser_url = "http://$url:$port"
    browser_cmd = `$browser --app=$browser_url --user-data-dir=$bp_dir --class="PlutoLauncher" --no-first-run`
    run(pipeline(browser_cmd, stdout=devnull, stderr=devnull), wait=true)
end

"""
    open_electron(url, port)

Opens Pluto in a new Electron window.
"""
function open_electron(url, port)

    # load Electron package
    @eval using Electron

    # explicitly import symbols into the current scope
    app = eval(:Electron).Application()
    Window = eval(:Window)

    # open window
    w_url = "http://$url:$port"
    window = Window(
        app,
        URI(w_url)
    )

    # block while window is open
    is_running = Condition()
    @async begin
        while isopen(window)
            sleep(0.2)
        end
        notify(is_running)
    end

    @info "Window open. Waiting till closed ..."
    wait(is_running)
    
    @info "Window Closed. Closing Electron ..."
    close(app)
end

"""
    pluto(args)

Starts the Pluto server if its not already running.
"""
function pluto(args)
    
    @info "Apply configuration ..."
    bp_dir, dof, url, port = get_config(args)
    browser, browser_path = get_browser()

    @info "Change to the working directory ..."
    if isdir(dof)
        cd(dof)
    else
        cd(dirname(dof))
    end

    @info "Starting pluto server ..."
    pluto_server = @async Pluto.run(
        host=url, 
        port=port, 
        launch_browser=false,
        require_secret_for_access=false,
        notebook= ifelse(isfile(dof) && endswith(dof, ".jl"), dof, nothing)
        )

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

    if !isnothing(browser)
        @info "Starting Browser $browser ..."
        open_browser(browser, bp_dir, url, port)
    else
        @info "Starting Electron app ..."
        open_electron(url, port)
    end

    # --- Block---
    
    @info "Window Closed. Closing Pluto ..."
    exit(0)
end

if abspath(PROGRAM_FILE) == @__FILE__
    pluto(ARGS)
end
