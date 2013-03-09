@App = @App || {}


$('#chart_title').text App.config.chart_title
$('#chart_longer_title').text App.config.chart_longer_title

Finch.route "/", (bindings) ->
	console.log "called Home!"
	if !App.initialized
		App.initialize(App.config.data.file)
	else if App.initialized
		console.log "Router: ", App.initialized

	
console.log "Listening!"
Finch.listen()

App.start_url_observer = () ->
	console.log "Starting observer"

	# This is the general listener:
	Finch.observe (params) ->
		console.log "observing..."

		if overlay = params('overlay')
			page = parseInt(params('page'))
			overlay_target= params('overlay_target')
			console.log "Observing overlay:", overlay, page, overlay_target
			

		if params('remove_blanks') == 'true'
			App.set_remove_blanks(true)
		else
			App.set_remove_blanks(false)

		App.sort_order(params('sort_order'))

		App.current_x_axis(params('x_axis'))


		if params('y_axis') != App.current_y_axis()
			target_y_axis = params('y_axis')
			App.current_y_axis(target_y_axis)
		else if !App.current_y_axis()
			App.current_y_axis(App.values[0])

		console.log 'Finch observing filters:', App.filters
		App.filters.forEach (f) ->
			if value_string = params(f)
				console.log f, value_string
				value_string.split(App.config.param_joiner).forEach (v) ->
					console.log(v)
					App.set_filter(f, v, "active")

		if overlay
			App.show_overlay(overlay_target, {page: page})
		else 
			App.render_dashboard()

	App.respond_to_html_changes = true

	Finch.navigate "/", {initialize: true}, true






