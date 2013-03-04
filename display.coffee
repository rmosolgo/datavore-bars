@App = @App || {}

App.plot_bars = (bar_data) ->	

	App.scale_x_to_fit(bar_data)

	bars = App.svg.selectAll(".bar")
		.data(bar_data)
		
	bars.enter().append('rect')
		.attr("class", "bar")
		.append("title")
				.text((d) -> d.year )
		
	bars.transition()
			.attr("x", (d,i) -> 110 + App.x_scale(d) + "px")
			.attr("y", (d) -> 50 + App.amount_scale(d.amount) + "px" )
			.attr("width", App.x_width )
			.attr("height", (d) -> 200 - App.amount_scale(d.amount)  )
			.style("fill", (d) -> App.amount_color_scale(d.amount))

	bars.on('mouseover', show_data)
	bars.on('mouseout', hide_data)


show_data = (d,i) ->
	$(this).attr("opacity", ".6")
	update_now_showing(d)

hide_data = (d, i) ->
	$(this).attr('opacity', '1')

App.get_filter_values = (column_name) ->
	$(".filters tr.#{column_name}.active")
		.children('.value').map((i,d) -> d.innerHTML.trim() )
		.get()

update_now_showing = (d) ->
	recipients =  App.get_filter_values("recipient").join(" and ") || "Africa"
	sectors = App.get_filter_values("sector").join(" and ") || "all sectors"
	flow_classes = App.get_filter_values("flow_class").join(" and ") || "all flow classes"
 
	$('#detail').text("In " +d.year+ ", " + 
		recipients  + " received $" + 
		d3.format(',.0f')(d.amount) + 
		" in " + sectors+ ".")

App.toggle_filter = (e) ->
	$(e).toggleClass('inactive').toggleClass('active')

	draw_from_filters()

App.set_all_filters = (set_to, e) ->
	if set_to == 'inactive'
		targets = $(e).parent().siblings('.active')
	else if set_to == 'active'
		targets = $(e).parent().siblings('.inactive')

	targets.toggleClass('inactive').toggleClass('active')

	draw_from_filters()

App.get_all_filters = () ->
	filter_types = ["recipient", "year", "sector", "flow_class"]
	filters = []

	filter_types.forEach( (f) ->
		filter_values = App.get_filter_values(f)
		filter = { key: f, values: filter_values}	 
		filters.push( filter )
		)

	filters

draw_from_filters = () ->
	
	filters = App.get_all_filters()
	console.log filters

	new_data = App.projects.where((table, row) ->
		passes = true

		filters.forEach((filter) ->
			if filter.values.length > 0 && !(table.get(filter.key,row) in filter.values)
				passes = false
				)
		passes

	)

	App.make_x_axis("year")
	App.make_yearly_sums(new_data)

	if d3.sum(filters.map((f) -> f.values.length )) == 0
		App.scale_y_to_fit(App.bar_data)

	App.plot_bars(App.bar_data)
	$('#detail').text("")



App.rescale = (bar_data) ->

	App.scale_y_to_fit(bar_data)
	App.plot_bars(bar_data)