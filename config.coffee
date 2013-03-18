@App = @App || {}

App.config =
	chart_title: "C10M, 2007-2010"
	chart_longer_title: "Cville 10 Miler, 2007-2010"

	vis_height: 300
	vis_width: 800
	vis_padding_left: 100
	vis_padding_top: 10
	vis_padding_bottom: 100

	# Set this to true to rescale
	# every time the vis renders.
	always_rescale_to_fit: false
	always_remove_blanks: false

	# joins params in the url
	param_joiner: '-and-'

	now_showing:
		# the now_showing object has a k:v for each of the filter columns
		# and ["measure"] for the active measure.
		# It should return a string to display in the to right.
		(ns) -> "#{ns.Year} #{ns.Gender} #{ns.measure} #{ns.Age} #{ns.State}."
	
	data:

		file: 
			# This is the relative path to the target data file.
			# "aiddata2_1_donor_recipient_year_purpose.csv"
			# "china_active.csv"
			"c10m.csv"

		get_file_size:
			# if true, shows loading bar
			# NOT IMPLEMENTED
			false

		preprocessing_function: 
			# This function is called on the loaded data file.
			 (data) -> (d for d in data)
			# (data) -> (d for d in data when parseInt(d.year) >=1980)

		record_hyperlink_function:
			# this returns the hyperlink for a given record.
			 (d) -> "" #"http://china.aiddata.org/projects/#{d.ProjectID}"
			
		columns: [
			# This is an array of objects with three attributes:
			#	name: 				becomes the name in the application
			#	values_function: 	function for populating this data field --> takes one argument, the csv data set.
			#	interface_type:		how is it used in the interface? one of: ["filter", "value", "none"]
			#	dv_type:			datavore column type, one of: [dv.type.ordinal, dv.type.nominal, dv.type.numeric]
			#	dv_measure: 		how this measure should be calculated ## 
			#	now_showing:		functions that take single values and multiple (array) and return things for the banner
			{
				name: "Count",
				values_function: (data) -> (1 for d in data)  #
				interface_type: "value",
				dv_type: dv.type.numeric
				dv_measure: dv.sum 
				now_showing:
					value: (d) -> "there were #{d} runners"
			},
			{
				name: "Average_Time",
				# in milliseconds
				values_function: (data) -> 
					data.map (d) ->
						time = d.guntime || d.chiptime || 0
						
						hours   = parseInt(time.replace(/^(\d)?:?\d\d:\d\d/, "$1")) || 0						
						minutes = parseInt(time.replace(/^(\d:)?(\d\d):.*$/, "$2")) || 0
						seconds = parseInt(time.replace(/^(\d:)?\d\d:(\d\d).*$/, "$2")) || 0
						# console.log "time:", time, "hours: ", hours, "minutes:", minutes, "seconds:", seconds					
						minutes = Math.round(10*((hours * 60) + minutes + (seconds/60)))/10

				interface_type: "value",
				dv_type: dv.type.numeric
				dv_measure: dv.avg 
				now_showing:
					value: (d) -> "the average was #{d3.format('.1f')(d)} minutes for these runners "
			},
			{
				name: "Year",
				values_function: (data) -> data.map((d) -> d.year),
				interface_type: "filter",
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "In #{single},"
					multiple: (multiple) -> "Over #{multiple.length} years, "
			},
			{
				name: "Name",
				values_function: (data) -> (d.name for d in data),
				interface_type: "none",
				dv_type: dv.type.nominal
				now_showing:
					single: (single) -> "" #In #{single},"
					multiple: (multiple) -> "" #Over #{multiple.length} years, "
			},
			# {
			# 	name: "City",
			# 	values_function: (data) -> ( d.city for d in data), #_condensed),
			# 	interface_type: "filter",
			# 	dv_type: dv.type.nominal
			# 	now_showing:
			# 		single: (single) -> "from #{single}"
			# 		multiple: (multiple) -> "" #"to #{multiple.length} countries "
			# },
			{
				name: "State",
				values_function: (data) -> (d.state || "Unknown" for d in data) 
				interface_type: "filter",
				dv_type: dv.type.nominal
				now_showing:
					single: (single) -> "from #{single}"
					multiple: (multiple) -> "from #{multiple.length} states"
			},
			{ 
				name: "Age"
				values_function: (data) -> (d.age || "Unknown" for d in data)
				interface_type: "filter"
				dv_type: dv.type.ordinal
				now_showing:
					single: (single) -> "who were #{single} years old"
					multiple: (multiple) -> "" #by #{multiple.length} modalities"
			},
			{
				name: "Gender",
				values_function: (data) -> (d.gender for d in data)
				interface_type: "filter",
				dv_type: dv.type.nominal
				now_showing:
					single: (single) -> 
						if single = 'M'
							g = "men" 
						else 
							g = "women"
						"for #{g},"

					multiple: (multiple) -> ""
			},
			# { 
			# 	name: "Club"
			# 	values_function: (data) -> data.map (d) ->
			# 		if d.club=="CTC" or d.club=="YES"
			# 			"Yes"
			# 		else
			# 			"No"
			# 	interface_type: "filter"
			# 	dv_type: dv.type.nominal
			# 	now_showing:
			# 		single: (single) -> ""
			# 		multiple: (multiple) -> "" #by #{multiple.length} modalities"
			# },
			# { 
			# 	name: "Place"
			# 	values_function: (data) -> (d.place for d in data)
			# 	interface_type: "filter"
			# 	dv_type: dv.type.ordinal
			# 	now_showing:
			# 		single: (single) -> ""
			# 		multiple: (multiple) -> "" #by #{multiple.length} modalities"
			# }
		]

$('title').text App.config.chart_title
$('#chart_title').text App.config.chart_title
$('#chart_longer_title').text App.config.chart_longer_title