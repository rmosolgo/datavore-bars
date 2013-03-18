@App = @App || {}

$('#overlay').on("hidden", App.render_url_from_html_state)
$('#overlay').on("shown", App.render_url_from_html_state)

App.show_overlay = (target, options) ->
	$('#overlay').modal('show')
	App.render_overlay_content(target,options)

App.render_overlay_content = (target,options) ->
	
	per_page= options?.per_page || 50
	page = options?.page || 1 
	console.log "overlay with:", options, "| page:", page, "| per_page:", per_page
	# filter data by html state 
	console.log "Getting all filters", target
	x_axis = App.current_x_axis()

	filters = (filter for filter in App.get_all_filters() when filter.key != x_axis)


	console.log "about to filter by click with x-axis", x_axis #  "on:", App.data

	filtered_data = App.data.where((table, row) ->
		passes = false
		# console.log "outer filter", target, table
		if (table.get(x_axis , row) == "#{target}")
			passes = true
			# console.log "inner filter", filter.key
			filters.forEach((filter) ->
				if ((filter.values.length > 0) && !(table.get(filter.key, row) in filter.values))				
					passes = false
				)	
		# console.log passes
		passes
	)

	console.log "filtering by ", filters , 'returned', filtered_data
	
	filtered_data = filtered_data[0].map((d,i) ->
		row = {}
		App.attributes.map((a) ->
			if filtered_data[a].type != 'numeric'
				row[a] = filtered_data[a].lut[filtered_data[a][i]]
			else 
				row[a] = filtered_data[a][i]
			)
		# console.log row
		row
	)

	filtered_data = _.sortBy(filtered_data, (d) -> -d[App.values[0]])
	# console.log "filtering by ", filters , 'returned', filtered_data

	number_of_rows = filtered_data.length

	start_on = (page-1)*per_page
	end_on = start_on + per_page 
	
	end_on = number_of_rows-1 if end_on > number_of_rows


	row_view = (table_row filtered_data[i],i for i in [start_on..end_on] )

	console.log "from #{start_on} to #{end_on} found #{row_view.length} rows:" #, row_view

	if page>1
		previous = 
			"<span class='pager-modal' onclick='App.render_overlay_content(#{target}, {page: #{page-1}})'>
				&larr; Prev 
			</span>"
	if number_of_rows > page * per_page
		next = 	
			"<span class='pager-modal'  onclick='App.render_overlay_content(#{target}, {page: #{page+1}})'>
				Next &rarr; 
			</span>"


	$('#overlay_header').html("
			#{previous || ""}
			<span id='overlay_target'>#{target}</span>:
			Showing records #{start_on+1}-#{end_on+1} of #{filtered_data.length}.
			#{next || ""}
	 ")

	$('.modal-body').html(
		"<table class='table table-hover'>
			#{table_headings(App.data)}
			#{row_view.join("")}
		</table>")

	$('.overlay-tooltip').tooltip()

	$('.modal-footer #page-number').text(page)

table_headings = (table) ->
	headings = (col.name for col in table)
	"<tr><th>#</th><th> #{ headings.join("</th><th>") }</th></tr>"

table_row = (item,i) ->
	values = []
	
	values = _.values(item)
	for k,v in item	
		values[k] = v 
	

	if hyperlinker = App.config.data.record_hyperlink_function
		href =  hyperlinker(item)
		#console.log href
		counter = 
			"<td>
				<a class='overlay-tooltip' 
					data-toggle='tooltip' 
					data-placement = 'right'
					title='See this record in a new window'
					style='color:#28a;' 
					href='#{href}'
					target='_blank'>
					#{i+1} <i class='icon-share'></i>
				</a>
			</td>"
	else
		counter = "<td>#{i+1}</td>"
	# console.log item, values

	"<tr>#{counter}<td>#{ values.join("</td><td>") }</td></tr>"			
