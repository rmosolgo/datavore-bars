
@App = @App || {}

App.svg = d3.select("#vis").append('svg')
		.attr("height", App.config.vis_height)
		.attr("width", App.config.vis_width)
		# .style("border", "2px solid #777")

d3.csv('china_active.csv', (data) ->

	data = data.filter((d) -> parseInt(d.year) >= 2000 )
	App.projects = dv.table()
	
	App.projects.addColumn(
		"amount", 
		data.map((d) -> Math.round(parseFloat(d.usd_defl || 0)) ),
		dv.type.numeric)
	App.projects.addColumn(
		"sector",
		data.map((d) ->  d.sector),
		dv.type.ordinal)
	App.projects.addColumn(
		"year",
		data.map((d) -> d.year),
		dv.type.ordinal)
	App.projects.addColumn(
		"recipient",
		data.map((d) -> d.recipient_condensed),
		dv.type.nominal)
	App.projects.addColumn(
		"flow_class",
		data.map((d) -> d.flow_class),
		dv.type.ordinal)


	App.recipient_names = App.projects[3].lut
	App.sector_names = App.projects[1].lut
	App.years = App.projects[2].lut

	App.flow_classes = App.projects[4].lut

	make_filter_selectors("recipient", App.recipient_names)
	make_filter_selectors("sector", App.sector_names)
	make_filter_selectors("flow_class", App.flow_classes)
	make_filter_selectors("year", App.years, "active")
	
	App.make_sums(App.projects, "year")
	App.scale_y_to_fit(App.bar_data)

	App.plot_bars()
)

make_filter_selectors = (column_name, values, default_active = "inactive") ->
	target = "##{column_name}_filters"

	$(target).append(
		"<tr>
			<th class='controller x_axis_controller btn' onclick='App.make_with_new_x_axis(\"#{column_name}\")'>
				Set this on X-axis
			</th>

			<th class='controller btn deactivator' onclick='App.set_all_filters(\"inactive\", this)'>
				Remove All
			</th>
			<th class='controller btn activator' onclick='App.set_all_filters(\"active\", this)'>
				Set all
			</th>
		</tr>")

	values.forEach((value,i) ->
		$(target).append(
			"<tr class='#{column_name} controller #{default_active}'
				onclick='App.toggle_filter(this)' >" +
			# <td class='column'> <b>#{column_name}:</b> </td>
			"<td class='value' > #{value} </td>
			</tr>")
	)



App.make_sums = (table, this_x_axis) ->
	console.log "Making sums by x-axis:", this_x_axis
	sum_result = table.query({
		dims: [this_x_axis],
		vals: [dv.sum('amount')],	
	})

	sums = sum_result[0].map((d,i) ->
		{key: d, value: sum_result[1][i]}
	)

	App.bar_data = sums
	

App.scale_y_to_fit = (bar_data) ->
	console.log "scale_y_to_fit", bar_data

	amount_domain = [
		0, 
		d3.max(bar_data.map((d) -> d.value))
		]

	cfg = App.config
	App.amount_scale = d3.scale.linear()
		.domain(amount_domain)
		.range([cfg.vis_height - cfg.vis_padding_top - cfg.vis_padding_bottom, 5])
		#.exponent(.5)

	y_axis = d3.svg.axis()
		.scale(App.amount_scale)
		.orient('right')
		 .tickFormat((amount) ->
				if 100 > amount 
					"#{d3.format("0,r")(d3.round(amount,0))}"
				else if 1000000 > amount >= 1000
					"#{d3.round((amount/1000),0)}K"
				else if 1000000000 > amount >= 1000000
					"#{d3.round((amount/1000000),1)}M"
				else if amount >= 1000000000
					"#{d3.format("0,r")(d3.round((amount/1000000000),2))}B")
		.ticks(4)

	App.amount_color_scale = d3.scale.linear()
		.domain([
			amount_domain[0],
			amount_domain[1]/2,
			amount_domain[1] * 1.1
			])
		.range(['blue', 'purple', 'red'])

	amount_axis = App.svg.selectAll('.amount_axis')
		.data([bar_data])

	amount_axis
		.enter().append('g')
		.attr('class', 'amount_axis')
		.attr('transform', "translate(10, #{cfg.vis_padding_top})")

	amount_axis	
		.call(y_axis)

