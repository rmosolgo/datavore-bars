
@App = @App || {}


App.initialized = false
App.respond_to_html_changes = false

App.initialize = (csv) ->

	
	console.log "pulling from csv"

	
	window.d3.csv(csv, (data) ->
		console.log("processing CSV")

		# console.log data.length
		
		if App.config.data.preprocessing_function
			data = App.config.data.preprocessing_function(data)

		App.data = dv.table()
		
		App.config.data.columns.forEach((c) ->
			App.data
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



		# Set these for access by other functions
		App.values = (d.name for d in App.config.data.columns when d.interface_type == 'value')
		App.filters = (d.name for d in App.config.data.columns when d.interface_type == 'filter')
		App.other_attributes = (d.name for d in App.config.data.columns when d.interface_type == 'none')
		App.attributes = (d.name for d in App.config.data.columns)

		make_filter_selectors App.filters
		

		make_value_selector(App.values)

		$('#filter_container .accordion-body').addClass("in")

		$('.filter_box').on('keyup', filter_these_options)

		App.initialized = true
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

make_filter_selectors = (filters) -> 
	filter_counter = 0
	container_counter = 0
	
	for f in filters 

		if filter_counter % 4 == 0
			container_counter += 1
			$('#filter_container').append("
				<div class='filter_subcontainer_#{container_counter} row-fluid'>
				</div>
				")

		make_filter_selector f, ".filter_subcontainer_#{container_counter}" 
		filter_counter +=1

make_filter_selector = (column_name, container_target, span_size = "3", default_active = "inactive") ->
	console.log "make filter selector for ", column_name, "in", container_target

	$(container_target).append(
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
				Deselect All
			</span>
			<span class='controller btn activator span6' onclick='App.set_all_filters(\"active\", \"#{column_name}\", true)'>
				Select Visible 
			</span>
		</div>
		<div class='row-fluid'>
			<span> 
				<input type='text' class='filter_box span12' value='Type to filter...' onfocus='this.value=\"\"'>
			</span>")

	App.data[column_name].lut.forEach((value,i) ->
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
	entry = e.target.value?.toLowerCase()
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

App.sort_orders = [
	{
		name: "a_to_z"
		text: "A &rarr; Z"
		function: (d) -> d.key
	}
	{
		name: "big_to_small"
		text: "Max &rarr; Min"
		function: (d) -> 
			-d.value
	}
]

