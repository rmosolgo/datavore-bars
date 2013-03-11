@App = @App || {}


App.export = (array_of_objects) ->
	
	console.log "exporting ", array_of_objects
	csv_header = headify array_of_objects

	csv_body = (csvify obj for obj in array_of_objects).join("
")

	csv = csv_header + csv_body

	console.log csv_header, csv_body
	csv_url = 'data:text/csv;charset=UTF-8,' + encodeURIComponent(csv)
	window.location =  csv_url


headify = (array_of_objects) ->
	item = array_of_objects[0]
	
	header = ("\"#{k}\"" for k, v in item).join(",") + "
"

csvify = (item) ->

	row = ("\"#{v}\"" for k, v in item).join(",")


App.export_chart_data = () ->
	data = App.render_dashboard()
	#prepared_data = ( {"#{d.key}" : d.value} for d in data )
	App.export(data)