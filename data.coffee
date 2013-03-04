
@App = @App || {}


pull_data_from_csv = (csv) ->
	console.log("looking for CSV")

	window.d3.csv(csv, (data) ->

		console.log("processing CSV")
		data = data.filter((d) -> parseInt(d.year) >= 1975 )

		App.projects = dv.table()
		
		App.projects.addColumn(
			"amount", 
			data.map((d) -> Math.round(parseFloat(d.commitment_usd_constant_sum || 0)) ), # d.usd_defl
			dv.type.numeric)
		App.projects.addColumn(
			"sector",
			data.map((d) ->  
				if d.coalesced_purpose_code 
					sector = "#{d.coalesced_purpose_code}, #{d.coalesced_purpose_name}" 
				else 
					sector = "000, not coded" 
				sector),
			dv.type.ordinal)
		App.projects.addColumn(
			"year",
			data.map((d) -> d.year),
			dv.type.ordinal)
		App.projects.addColumn(
			"recipient",
			data.map((d) -> d.recipient),
			dv.type.nominal)
		App.projects.addColumn(
			"donor",
			data.map((d) -> d.donor),
			dv.type.ordinal)

		initialize_dashboard()
	)


initialize_dashboard = () ->
	console.log("initializing dashboard")
	
	$('#waiting').remove()

	App.recipient_names = App.projects[3].lut
	App.sector_names = App.projects[1].lut
	App.years = App.projects[2].lut

	App.donors = App.projects[4].lut

	make_filter_selectors("recipient", App.recipient_names)
	make_filter_selectors("sector", App.sector_names)
	make_filter_selectors("donor", App.donors)
	make_filter_selectors("year", App.years, "active")

	$('.filter_box').on('keyup', filter_these_options)

	App.make_sums(App.projects, "year")
	App.scale_y_to_fit(App.bar_data)

	App.plot_bars()

make_filter_selectors = (column_name, values, default_active = "inactive") ->
	target = "##{column_name}_filters"

	$(target).append(
		"<tr>
			<th><h2>#{column_name}</h2>
			</th>"
		"<tr>
			<th class='controller x_axis_controller btn' onclick='App.make_with_new_x_axis(\"#{column_name}\")'>
				Set this on X-axis
			</th>
		</tr>
		<tr>

			<th class='controller btn deactivator' onclick='App.set_all_filters(\"inactive\", this)'>
				Remove All
			</th>
			<th class='controller btn activator' onclick='App.set_all_visible_filters(\"active\", this)'>
				Select Visible 
			</th>
		</tr>
		<tr>
			<th> <input type='text' class='filter_box' value='Type to filter...' onfocus='this.value=\"\"'>
				</th>
		</tr>")

	values.forEach((value,i) ->
		$(target).append(
			"<tr data-searcher='#{value.toLowerCase()}' class='#{column_name} controller #{default_active}'
				onclick='App.toggle_filter(this)' >
			<td class='value' > #{value} </td>
			</tr>")
	)


filter_these_options = (e) ->
	# console.log "e: ", e, "this: ", this
	entry = e.target.value.toLowerCase()
	# console.log(entry)
	if entry.length > 0
		rows = $(e.target).parent().parent().parent().children()
		# console.log rows
		rows.each((i,d) ->
			if s = $(d).attr("data-searcher")
				# console.log(d, s)
				if s.indexOf(entry) > -1
					$(d).css("display", "inherit")
				else 
					$(d).css("display", "none")
			)




App.make_sums = (table, this_x_axis) ->
	# console.log "Making sums by x-axis:", this_x_axis
	sum_result = table.query({
		dims: [this_x_axis],
		vals: [dv.sum('amount')],	
	})

	sums = sum_result[0].map((d,i) ->
		{key: d, value: sum_result[1][i]}
	).filter((d) -> d.value > 0)

	App.bar_data = sums
	

App.scale_y_to_fit = (bar_data) ->
	# console.log "scale_y_to_fit", bar_data

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



# INITIALIZE

App.svg = d3.select("#vis").append('svg')
		.attr("height", App.config.vis_height)
		.attr("width", App.config.vis_width)
		# .style("border", "2px solid #777")

if localStorage.aiddata2_1_v_1
	console.log "found local data"
	App.projects = localStorage.aiddata2_1_v_1
	initialize_dashboard()
else
	console.log "pulling from csv"
	pull_data_from_csv("aiddata2_1_donor_recipient_year_purpose.csv")
	# pull_data_from_csv("china_active.csv")
	# initialize dashboard after ajax call