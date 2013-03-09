@App = @App || {}

show_data = (d,i) ->
	# console.log d
	$(this).attr("opacity", ".6")
	update_now_showing(d)


hide_data = (d, i) ->
	$(this).attr('opacity', '1')


update_now_showing = (d) ->
	# console.log(d)
	filters = App.get_all_filters({all_if_none: true})
	now_showing = {}

	filters.forEach((filter) ->
		values = filter.values
		key = filter.key
		this_column = (c for c in App.config.data.columns when c.name is key)[0]
		# console.log values, key, this_column
		if this_column?
			if key == App.current_x_axis()
				now_showing[this_column.name] = this_column.now_showing.single(d.key)
			else if values.length > 1 
				now_showing[this_column.name] = this_column.now_showing.multiple(values) 
			else 
				now_showing[this_column.name] = this_column.now_showing.single(values[0])

		measure = (c for c in  App.config.data.columns when c.name is App.current_y_axis() )[0]
		# console.log measure
		if measure?
			now_showing["measure"] = measure.now_showing.value(d.value)
	)

	now_showing_string = App.config.now_showing(now_showing)
	
	console.log "now_showing", now_showing, "string: ", now_showing_string
	$('#detail').text(now_showing_string)


scale_y_to_fit = (bar_data) ->
	# console.log "scale_y_to_fit", bar_data
	$('#rescale').removeClass("btn-warning").addClass("btn-primary")

	amount_domain = [
		0, 
		d3.max(bar_data.map((d) -> d.value))
		]

	cfg = App.config

	App.amount_scale = d3.scale.linear()
		.domain(amount_domain)
		.range([cfg.vis_height - cfg.vis_padding_top - cfg.vis_padding_bottom, 5])
		#.ticks(6)
		#.exponent(.5)

	y_axis = d3.svg.axis()
		.scale(App.amount_scale)
		.orient('right')
		.tickFormat((amount) ->
				if 1000 >= amount 
					"#{d3.format("0,r")(d3.round(amount,0))}"
				else if 1000000 > amount >= 1000
					"#{d3.round((amount/1000),0)}K"
				else if 1000000000 > amount >= 1000000
					"#{d3.round((amount/1000000),1)}M"
				else if amount >= 1000000000
					"#{d3.format("0,r")(d3.round((amount/1000000000),2))}B")
		.ticks(6)

	App.amount_color_scale = d3.scale.linear()
		.domain([
			amount_domain[0],
			amount_domain[1]/2,
			amount_domain[1] * 1.1
			])
		.range(['blue', 'purple', 'red'])

	y_axis_svg = App.svg.selectAll('.y_axis')
		.data([bar_data])

	y_axis_svg
		.enter().append('g')
		.attr('class', 'y_axis')
		.attr('transform', "translate(10, #{cfg.vis_padding_top})")

	y_axis_svg
		.call(y_axis)




App.render_dashboard = (options) ->
	# by this api, event listeners need only to alter the HTML state, 
	# then call this function.

	# except for these options:
	rescale_y_by_request = options?.rescale_y || false

	# reset now_showing
	$('#detail').html("<i>Mouseover for detail</i>")

	# filter data by html state 
	console.log "Getting all filters"
	filters = App.get_all_filters()

	filtered_data = App.projects.where((table, row) ->
		passes = true
		filters.forEach((filter) ->
			if (filter.values.length > 0 && !(table.get(filter.key, row) in filter.values))				
				passes = false
			)	
		# console.log passes
		passes
	)
	console.log "filtering by ", filters #, 'returned', filtered_data

	# calculate sums by x-axis
	this_x_axis = App.current_x_axis()

	console.log "x-axis:", this_x_axis

	sum_result = filtered_data.query({
		dims: [this_x_axis],
		# This needs to be abstracted
		vals: [dv.sum(App.current_y_axis())],
		# i tried using sparse query and where, but it was ~slow~!
		})

	console.log "starting to make sums"
	html_state_sums = sum_result[0].map((d,i) ->
		{key: d, value: sum_result[1][i]}
	)

	console.log "summing by", this_x_axis, "returned", html_state_sums
	
	# render new x-axis
	if App.remove_blanks() || App.config.always_remove_blanks 
		prepared_data = (s for s in html_state_sums when s.value > 0)

	else
		active_x_values = App.get_filter_values(this_x_axis, {all_if_none: true})
		prepared_data = (s for s in html_state_sums when s.key in active_x_values )

	console.log "about to make my domain:", prepared_data	
	domain = _.sortBy(prepared_data, App.sort_order_function() ).map((d) -> d.key)

	console.log "Making x axis by", this_x_axis,"with these values", domain

	x_scale = d3.scale.ordinal()
			.domain(domain)
			.rangeBands([0,App.config.vis_width - App.config.vis_padding_left], .1)

	x_width = (700 * .9)/domain.length

	x_axis = d3.svg.axis()
		.scale(x_scale)
		.orient('bottom')

	console.log "rendering this_x_axis to this_x_axis_svg"
	this_x_axis_svg = App.svg.selectAll('.x_axis')
		.data([this_x_axis])

	this_x_axis_svg
		.enter().append('g')
		.attr('class', 'x_axis')
		.attr('transform', "translate(#{App.config.vis_padding_left}, #{App.config.vis_height - App.config.vis_padding_bottom})")

	this_x_axis_svg
		.call(x_axis)
		.selectAll("text")
			.style("text-anchor", "end")
			.attr("dx", "-.8em")
			.attr("dy", ".15em")
			.attr("transform", (d) -> "rotate(-65)"  );

	# rebind data to objects
	
	# Y-SCALE still controlled separately
	if !App.amount_scale || rescale_y_by_request
		console.log "Fetching a new y-scale"
		scale_y_to_fit(prepared_data)
	
	console.log "binding and rendering new bars"
	bars = App.svg.selectAll(".bar")
		.data(prepared_data, (d) -> d.key )
		
	bars.enter().append('rect')
		.attr("class", "bar")

	bars.exit().remove()

	the_graph_is_too_big = false
	the_graph_is_too_small = false
	biggest_bar = 0
	max_bar_h = (App.config.vis_height - App.config.vis_padding_top - App.config.vis_padding_bottom)

	bars.transition()
			.delay((d,i) -> i*10 )
			.attr("x", (d,i) -> "#{ App.config.vis_padding_left + x_scale(d.key) }px")
			.attr("y", (d) -> App.config.vis_padding_top + App.amount_scale(d.value) + "px" )
			.attr("width", x_width )
			.attr("height", (d) -> 
				h = max_bar_h - App.amount_scale(d.value) 
				if h > max_bar_h
					the_graph_is_too_big = true
				if h > biggest_bar
					biggest_bar = h
				h + "px" )
			.style("fill", (d) -> App.amount_color_scale(d.value) )

	console.log "resizing according to calculated sizes"
	if biggest_bar < (max_bar_h/2) 
		the_graph_is_too_small = true

	if the_graph_is_too_small
		$('#rescale').removeClass("btn-primary").addClass("btn-warning")
	else 
		$('#rescale').addClass("btn-primary").removeClass("btn-warning")

	if the_graph_is_too_big || App.config.always_rescale_to_fit 
		scale_y_to_fit(prepared_data)		
		bars.transition()
			.delay((d,i) -> ((i*20) + 250))
			.attr("y", (d) -> App.config.vis_padding_top + App.amount_scale(d.value) + "px" )
			.attr("height", (d) -> 
				h = max_bar_h - App.amount_scale(d.value) 
				h + "px" )
			.style("fill", (d) -> App.amount_color_scale(d.value) )

	bars
		.on('mouseover', show_data)
		.on('mouseout', hide_data)
		.on('click', (d,i) -> App.show_overlay(d.key, {page: 1}))
	console.log "finished rendering!"

