
using Pluto

"""
    start_pluto()

Starts the Pluto server.
"""
function start_pluto()
    
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
        launch_browser=false
        )

end

if abspath(PROGRAM_FILE) == @__FILE__
    start_pluto()
end
