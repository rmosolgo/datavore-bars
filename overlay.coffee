@App = @App || {}

App.show_overlay = (d,i) ->

	# filter data by html state 
	console.log "Getting all filters", d
	x_axis = App.current_x_axis()

	# shortNames = (name for name in list when name.length < 5)
	
	filters = (filter for filter in App.get_all_filters() when filter.key != x_axis)


	console.log "about to filter by click with x-axis", x_axis #  "on:", App.projects

	filtered_data = App.projects.where((table, row) ->
		passes = false
		# console.log "outer filter", d.key, d.value, table
		if (table.get(x_axis , row) == d.key)
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


	number_of_columns = filtered_data.length
	
	start_on = 0
	end_on = 50

	# row_view = filtered_data[0].map((d,i) ->
	# 	vals = []
	# 	j = 0
	# 	while j <= number_of_columns
	# 		vals.push(filtered_data[j][i])
	# 	vals
	# 	)

	# console.log "rows:", row_view
