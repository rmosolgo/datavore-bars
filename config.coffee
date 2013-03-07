@App = @App || {}

App.config = 
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

	data:

		file: 
			# This is the relative path to the target data file.
			 "aiddata2_1_donor_recipient_year_purpose.csv"
			# "china_active.csv"

		get_file_size:
			# if true, shows loading bar
			# NOT IMPLEMENTED
			false

		preprocessing_function: 
			# This function is called on the loaded data file.
			(data) -> data.filter((d) -> parseInt(d.year) >= 1980 )
			
		columns: [
			# This is an array of objects with three attributes:
			#	name: 				becomes the name in the application
			#	values_function: 	function for populating this data field --> takes one argument, the csv data set.
			#	interface_type:		how is it used in the interface? one of: ["filter", "value"]
			#	dv_type:			datavore column type, one of: [dv.type.ordinal, dv.type.nominal, dv.type.numeric]
			#	
			{
				name: "Commitment",
				values_function: (data) -> data.map((d) -> Math.round(parseFloat( d.commitment_usd_constant_sum  || 0)) ), # d.usd_defl
				interface_type: "value",
				dv_type: dv.type.numeric
			},
			{
				name: "Count",
				values_function: (data) -> data.map((d) -> 1),
				interface_type: "value",
				dv_type: dv.type.numeric
			},
			{
				name: "year",
				values_function: (data) -> data.map((d) -> d.year),
				interface_type: "filter",
				dv_type: dv.type.ordinal
			},
			{
				name: "recipient",
				values_function: (data) -> data.map((d) -> d.recipient), #_condensed),
				interface_type: "filter",
				dv_type: dv.type.nominal
			},
			{
				name: "donor",
				values_function: (data) -> data.map((d) -> d.donor),
				interface_type: "filter",
				dv_type: dv.type.ordinal
			},
			# { 
			# 	name: "flow_class"
			# 	values_function: (data) -> data.map((d) -> d.flow_class)
			# 	interface_type: "filter"
			# 	dv_type: dv.type.ordinal
			# },
			{
				name: "sector",
				values_function: (data) -> data.map((d) ->  # d.sector)
						if d.coalesced_purpose_code 
							sector = "#{d.coalesced_purpose_code}, #{
								d.coalesced_purpose_name
									.toLowerCase()
									.replace(/\&/g, 'and')
									.replace(/'/g, '')
									.trim() }" 
						else 
							sector = "000, not coded" 
						sector),
				interface_type: "filter",
				dv_type: dv.type.ordinal
			},
		]

