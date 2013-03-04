@App = @App || {}



App.toggle_filter = (e) ->
	$(e).toggleClass('inactive').toggleClass('active')

	App.draw_from_filters()

App.set_all_filters = (set_to, e) ->
	if set_to == 'inactive'
		targets = $(e).parent().siblings('.active')
	else if set_to == 'active'
		targets = $(e).parent().siblings('.inactive')

	targets.toggleClass('inactive').toggleClass('active')

	App.draw_from_filters()

App.get_filter_values = (column_name) ->
	$(".filters tr.#{column_name}.active")
		.children('.value').map((i,d) -> d.innerHTML.trim() )
		.get()

App.get_all_filters = () ->
	filter_types = ["recipient", "year", "sector", "flow_class"]
	filters = []

	filter_types.forEach( (f) ->
		filter_values = App.get_filter_values(f)
		filter = { key: f, values: filter_values}	 
		filters.push( filter )
		)
	# console.log "Get all filters", filters
	filters

App.rescale = () ->
	App.scale_y_to_fit(App.bar_data)
	App.plot_bars()

