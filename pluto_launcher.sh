	# 1. Prüfe, ob Project.toml existiert, sonst erstelle Projekt und starte Pluto
    	if [ ! -f "Project.toml" ]; then
        	echo "Kein Projekt gefunden. Initialisiere neues Julia-Projekt in $(pwd) und starte Pluto"
        	julia --threads auto -e '
        		using Pkg
        		Pkg.activate(".")
        		Pkg.add("Pluto")
        		using Pluto
        		Pluto.run()
        	'
	else
		echo "Julia Projekt gefunden. Starte Pluto"
		julia --threads auto --project=. -e '
			using Pkg
			if !haskey(Pkg.dependencies(), "Pluto")
                		Pkg.add("Pluto")
			end
			using Pluto
			Pluto.run()
		'
    	fi