
using Pluto

"""
    pluto(args)

Starts the Pluto server if its not already running.
"""
function pluto()
    
    # config
    url = "127.0.0.1"
    port = 13254
    notebook_dir = joinpath(homedir(), "PlutoNotebooks")

    # create notebook dir
    mkpath(notebook_dir)
    cd(notebook_dir)

    @info "Starting pluto server ..."
    Pluto.run(
        host=url, 
        port=port, 
        launch_browser=false,
        require_secret_for_access=false
        )

end

if abspath(PROGRAM_FILE) == @__FILE__
    pluto()
end
