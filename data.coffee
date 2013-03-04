
@App = @App || {}

App.svg = d3.select("#vis").append('svg')
		.attr("height", '300px')
		.attr("width", '800px')
		.style("border", "2px solid #777")

d3.csv('china_active.csv', (data) ->

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


	App.make_yearly_sums(App.projects)
	
	App.scale_y_to_fit(App.bar_data)

	App.plot_bars(App.bar_data)
)

make_filter_selectors = (column_name, values, default_active = "inactive") ->
	target = "##{column_name}_filters"

	$(target).append(
		"<tr>
			<th class='controller btn' onclick='App.set_all_filters(\"active\", this)'>
				Set all
			</th>
			<th class='controller btn' onclick='App.set_all_filters(\"inactive\", this)'>
				Remove All
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



App.make_yearly_sums = (table) ->
	yearly_sum_result = table.query({
		dims: ["year"],
		vals: [dv.sum('amount')],	
	})

	yearly_sums = yearly_sum_result[0].map((d,i) ->
		{year: d, amount: yearly_sum_result[1][i]}
	)

	App.bar_data = yearly_sums
	

App.make_x_axis = (column) ->
	domain = App.get_filter_values(column)

	App._x_scale_calculator = d3.scale.ordinal()
			.domain(domain)
			.rangeBands([0,650], .1)

	App.x_scale = (d) -> 
		App._x_scale_calculator(d[column])

	App.x_width = (700 * .9)/domain.length

	App.x_axis = d3.svg.axis()
		.scale(App._x_scale_calculator)
		.orient('bottom')
		# .tickFormat()
		# .ticks(6, (d) -> "$" + d/1000000000 + " bil")

App.scale_y_to_fit = (bar_data) ->
	console.log "scale_y_to_fit", bar_data

	amount_domain = [
		0, 
		d3.max(bar_data.map((d) -> d.amount))
		]

	App.amount_scale = d3.scale.pow()
		.domain(amount_domain)
		.range([200, 5])
		.exponent(.5)

	y_axis = d3.svg.axis()
		.scale(App.amount_scale)
		.orient('right')
		# .tickFormat()
		.ticks(6, (d) -> "$" + d/1000000000 + " bil")

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
		.attr('transform', 'translate(10,100)')

	amount_axis	
		.call(y_axis)

App.scale_x_to_fit = (bar_data) ->

	this_x_axis = App.svg.selectAll('.x_axis')
		.data([bar_data])

	this_x_axis
		.enter().append('g')
		.attr('class', 'x_axis')
		.attr('transform', 'translate(110,250)')

	this_x_axis	
		.call(App.x_axis)