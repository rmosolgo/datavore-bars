@App = @App || {}

App.render_url_from_html_state = () ->
	url_params = {}

	url_params["x_axis"] = App.current_x_axis()
	url_params["y_axis"] = App.current_y_axis()
	
	url_params["remove_blanks"] = "#{App.remove_blanks()}"

	App.get_all_filters().forEach((f) ->
		if f.values.length > 0
			url_params[f.key] = f.values.join(App.config.param_joiner)
		)
	console.log 'navigating to', url_params
	Finch.navigate url_params



App.current_x_axis = (column) ->
	# sets to column if provided, always returns column name
	# console.log "provided x-axis: ", column
	if column 
		$('.x_axis_controller').removeClass("current_x_axis")
		button = $("##{column}_accordion .x_axis_controller").addClass('current_x_axis')
		console.log 'requesting new with x-axis:', column #, 'selector:', button	
		App.render_url_from_html_state()


	$('.current_x_axis').attr("data-column-name")


App.current_y_axis = (column) ->
	# sets to column if provided, always returns column name
	
	if column 
		console.log "provided y-axis: ", column
		$('.y_axis_controller').removeClass("current_y_axis")
		button = $("#value_container .y_axis_controller.#{column}").addClass('current_y_axis')
		console.log 'requesting new with y-axis:', column , 'selector:', button	
		App.render_url_from_html_state()
		App.rescale()

	$('.current_y_axis').attr("data-column-name")


	
App.remove_blanks = () ->
	# returns true or false
	remove_blanks_element = $('#remove_blanks')
	html_remove_blanks_state = remove_blanks_element.hasClass("btn-success")
	

App.toggle_filter = (e) ->
	this_filter = $(e)
	this_column = $(e).attr("data-column")
	this_value = $(e).attr("data-value")

	if this_filter.hasClass("inactive")
		App.set_filter(this_column, this_value, 'active')
	else
		App.set_filter(this_column, this_value, 'inactive')


App.set_filter = (column, value, set_to = "active") ->
	console.log "set filter: #{value} -> #{set_to}" 
	if target = $(".#{column}.value[data-value='#{value}']")
		target
			.removeClass('active')
			.removeClass('inactive')
			.addClass(set_to)
		console.log(target)
		App.render_url_from_html_state()

App.set_all_filters = (set_to, column, visible_only = false) ->	
	if set_to == 'inactive'
		targets = $(".#{column}.value.active")
	else if set_to == 'active'
		targets = $(".#{column}.value.inactive")

	if visible_only
		targets.each((i,d) ->
			if $(d).is(':visible')
				$(d).toggleClass('inactive').toggleClass('active')
		)	
	else
		targets.toggleClass('inactive').toggleClass('active')

	console.log "set all filters to ", set_to, column, targets, "visible_only", visible_only

	App.render_url_from_html_state()

App.get_filter_values = (column_name, options) ->
	get_all_if_none = options?.all_if_none || false

	values = $(".filters .#{column_name}.active.value")
		.map((i,d) -> d.innerHTML.trim() )
		.get()

	if values.length == 0 && get_all_if_none
		values = $(".filters .#{column_name}.value")
			.map((i,d) -> d.innerHTML.trim() )
			.get()
		console.log "got values because none", values			
	values

App.get_all_filters = () ->
	filter_types = App.filters
	filters = []

	filter_types.forEach( (f) ->
		filter_values = App.get_filter_values(f)
		filter = { key: f, values: filter_values}	 
		filters.push( filter )
		)
	# console.log "Get all filters", filters
	filters




App.rescale = () ->
	App.render_dashboard_from_url_state({rescale_y: true})

App.set_remove_blanks = (set_to) ->
	remove_blanks_element = $('#remove_blanks')
	
	if set_to == true
		remove_blanks_element.removeClass("btn-danger").addClass("btn-success")
		remove_blank_status = 'On'
	else
		remove_blanks_element.addClass("btn-danger").removeClass("btn-success")
		remove_blank_status =   'Off'

	remove_blanks_element.text("Remove blanks: #{remove_blank_status}")
	App.render_url_from_html_state()

App.toggle_remove_blanks = () ->
	if App.remove_blanks() == true
		App.set_remove_blanks(false)
	else 
		App.set_remove_blanks(true)
		
	
	
	