
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

	App.recipient_names = App.projects[3].lut
	App.sector_names = App.projects[1].lut
	App.years = App.projects[2].lut

	typeahead_template = 
		"<span class='value'>{{value}}</span>" +
		"<span class='hint'>Filter by this {{type}} </span>"

	$('#omnibar').typeahead([
		{
			name: 'recipient_names',
			local: App.recipient_names.map((n) ->  
				{ value: n, tokens: [n], type: "country" } ),
			template: typeahead_template,
			engine: Hogan
		},
		{
			name: 'sector'
			local: App.sector_names.map((n) ->
				{ value: n, tokens: n.split(" "), type: "sector"})
			template: typeahead_template,
			engine: Hogan
		}
	])
		
	

	App.make_yearly_sums(App.projects)
	App.scale_to_fit(App.bar_data)
	App.plot_bars(App.bar_data)
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
	


App.scale_to_fit = (bar_data) ->
	console.log "scale_to_fit", bar_data
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

