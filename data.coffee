
@App = @App || {}

App.initialized = () ->
	# returns "Is the app loaded?" from html state
	if $('.current_x_axis')[0]
		initialized = true
	else 
		initialized = false
	initialized

App.initialize = (csv) ->
	console.log "pulling from csv"
		
	if App.config.data.get_file_size

		start_time = new Date
		xhr = $.ajax(
			type: "HEAD",
			url: App.config.data.file,
			success: (msg) ->
				file_size_in_bytes = parseInt(xhr.getResponseHeader('Content-Length'))
				console.log "xhr: ", xhr
				console.log file_size_in_bytes, "bytes"	
				elapsed_time = new Date - start_time
				console.log elapsed_time
		)

	
	window.d3.csv(csv, (data) ->
		console.log("processing CSV")

		console.log data.length
		
		if App.config.data.preprocessing_function
			data = App.config.data.preprocessing_function(data)

		App.projects = dv.table()
		
		App.config.data.columns.forEach((c) ->
			App.projects
				.addColumn(
					# These are defined in config.coffee
					c.name, 
					c.values_function(data), 
					c.dv_type
					)
			)

		$('#waiting').remove()

		App.svg = d3.select("#vis").append('svg')
				.attr("height", App.config.vis_height)
				.attr("width", App.config.vis_width)


		App.config.data.columns.forEach((d,i) ->
			if d.interface_type == "filter"
				make_filter_selectors(d.name, App.projects[i].lut, 3) # span 3
			)

		# Set these for access by other functions
		App.values = App.config.data.columns.filter((d) -> d.interface_type == 'value').map((d) -> d.name )
		App.filters = App.config.data.columns.filter((d) -> d.interface_type == 'filter').map((d) -> d.name )

		make_value_selector(App.values)

		$('#filter_container .accordion-body').addClass("in")

		$('.filter_box').on('keyup', filter_these_options)
		console.log("finished loading")
		App.start_url_observer()


	)

make_value_selector = (values) ->
	$("#value_container").append(
			"<b>Measure: </b>"
			values.map((v) -> "<span class='btn controller y_axis_controller #{v}' data-column-name='#{v}'
									onclick='App.current_y_axis(\"#{v}\")'>
									#{v}
								</span>").join(" ")
		)

make_filter_selectors = (column_name, values, span_size = "3", default_active = "inactive") ->


	$('#filter_container').append(
			"<div class='accordion-group span#{span_size}'>

				<div class='accordion-heading'>
					<span class='accordion-toggle' data-toggle='collapse' data-parent='#filter_container' >
						Filter by #{column_name}:
					</span>
				</div>

 				<div id='collapse_#{column_name}' class='accordion-body collapse'>
					<div class='accordion-inner' id='#{column_name}_accordion'>
						<div class='controls'>
							</div>
						<div class='filters'>
						</div>
					</div>
				</div>

			</div>")
		# "<table class='filters  table-hover span3' id='#{column_name}_filters'></table>"

	target = "##{column_name}_accordion"

	$("#{target} .controls").append(
		"
		<div class='row-fluid'>
			<a class='controller x_axis_controller btn span12' data-column-name='#{column_name}' onclick='App.current_x_axis(\"#{column_name}\")'>
					Set this on X-axis
			</a>
		</div>
		<div class='row-fluid'>
			<span class='controller btn deactivator span6' onclick='App.set_all_filters(\"inactive\", \"#{column_name}\")'>
				Remove All
			</span>
			<span class='controller btn activator span6' onclick='App.set_all_filters(\"active\", \"#{column_name}\", true)'>
				Select Visible 
			</span>
		</div>
		<div class='row-fluid'>
			<span> 
				<input type='text' class='filter_box span12' value='Type to filter...' onfocus='this.value=\"\"'>
			</span>")

	values.forEach((value,i) ->
		$("#{target} .filters").append(
			"<span 
				data-searcher='#{value.toLowerCase()}' 
				data-value='#{value}' 
				data-column='#{column_name}'
				class='#{column_name} controller #{default_active} value'
				onclick='App.toggle_filter(this)'
			>
				#{value}
			</span>")
	)


filter_these_options = (e) ->
	# console.log "e: ", e, "this: ", this
	entry = e.target.value.toLowerCase()
	# console.log(entry)
	rows = $(e.target).closest('.accordion-group').find('.value')
	
	if entry.length > 0
		# console.log rows
		rows.each((i,d) ->
			if entry == $(d).attr("data-searcher").substr(0, entry.length)
				$(d).css("display", "inherit")
			else 
				$(d).css("display", "none")
			)
	else 
		rows.css("display", "inherit")



