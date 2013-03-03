@App = @App || {}

App.plot_bars = (bar_data) ->	

	bars = App.svg.selectAll(".bar")
		.data(bar_data)
		
	bars.enter().append('rect')
		.attr("class", "bar")
		.append("title")
				.text((d) -> d.year )
		
	bars.transition()
			.attr("x", (d,i) -> 100+ (i*50) + "px")
			.attr("y", (d) -> 100 + App.amount_scale(d.amount) + "px" )
			.attr("width", "45px")
			.attr("height", (d) -> 200 - App.amount_scale(d.amount)  )
			.style("fill", (d) -> App.amount_color_scale(d.amount))

	bars.on('mouseover', show_data)
	bars.on('mouseout', hide_data)


show_data = (d,i) ->
	$(this).attr("opacity", ".6")
	update_now_showing(d)

hide_data = (d, i) ->
	$(this).attr('opacity', '1')

update_now_showing = (d) ->
	recipients =  $('.filters tr.recipient td.active').siblings('.value').map((i,d) -> d.innerHTML ).get().join(" and ") || "Africa"
	sectors =  $('.filters tr.sector td.active').siblings('.value').map((i,d) -> d.innerHTML ).get().join(" and ") || "all sectors"
 
	$('#detail').text("In " +d.year+ ", " + 
		recipients  + " received $" + 
		d3.format(',.0f')(d.amount) + 
		" in " + sectors+ ".")

App.toggle_filter = (e) ->
	$(e).toggleClass('inactive').toggleClass('active')

	if $(e).hasClass('active')
		$(e).text("Active")
	else
		$(e).text("Inactive")

	draw_from_filters()

draw_from_filters = () ->
	recipients =  $('.filters tr.recipient td.active').siblings('.value').map((i,d) -> d.innerHTML.trim() ).get()
	sectors =  $('.filters tr.sector td.active').siblings('.value').map((i,d) -> d.innerHTML.trim() ).get()
	console.log recipients, sectors
	new_data = App.projects.where((table, row) ->
		passes = true
		if recipients.length > 0 && !(table.get("recipient",row) in recipients)
			passes = false
		if sectors.length > 0 && !(table.get("sector", row) in sectors)
			passes = false
		passes
	)

	App.make_yearly_sums(new_data)

	if recipients.length == 0 && sectors.length == 0
		App.scale_to_fit(App.bar_data)

	App.plot_bars(App.bar_data)
	$('#detail').text("")



App.rescale = (bar_data) ->

	App.scale_to_fit(bar_data)
	App.plot_bars(bar_data)