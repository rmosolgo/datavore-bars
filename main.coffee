@App = @App || {}


Finch.route "/", (bindings) ->
	console.log "called home!"
	if !App.initialized()
		App.initialize(App.config.data.file)
	else
		if !App.current_x_axis()
			App.current_x_axis("year")

Finch.listen()


App.start_url_observer = () ->
	
	
	# This is the general listener:
	Finch.observe (params) ->
		remove_blanks = params('remove_blanks')
		console.log "URL remove blanks? ", remove_blanks
		
		if remove_blanks == 'true'
			App.set_remove_blanks(true)
		else
			App.set_remove_blanks(false)

		if params('x_axis') != App.current_x_axis()
			target_x_axis = params('x_axis') || App.filters[0]
			App.current_x_axis(target_x_axis)
		
		if params('y_axis') != App.current_y_axis()
			target_y_axis = params('y_axis') || App.values[0]
			App.current_y_axis(target_x_axis)

		console.log 'Finch observing filters:', App.filters
		App.filters.forEach (f) ->
			if value_string = params(f)
				console.log f, value_string
				value_string.split(App.config.param_joiner).forEach (v) ->
					console.log(v)
					App.set_filter(f, v, "active")

		App.render_dashboard_from_url_state()

	# This is an initializer:
	if !App.current_x_axis()
		App.current_x_axis(App.filters[0])
	
	if !App.current_y_axis()
		App.current_y_axis(App.values[0])


