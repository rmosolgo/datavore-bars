
# Datavore-bars

Datavore bars is a configurable plug-in for graphing data. It takes a CSV and creates a simple dashboard.

It runs on:

- [Datavore](http://vis.stanford.edu/projects/datavore/) for data management
- [D3](d3js.org) for the dashboard vis
- [Finch](http://stoodder.github.com/finchjs) for RESTful URLs
- Underscore.js for a little bit of data manipulation
- jQuery
- Bootstrap (via Bootswatch)
- LESS
- CoffeeScript

## Configuration

To configure, alter `App.config` values found in config.coffee. See comments in the source for details.

### Display:

__App.config.chart_title__ and __App.config.chart_longer_title__ give names for the dashboard and loading overlay.

__App.config.now_showing__ is a function that turns your columns into a sentence in the top left corner.

### Data:
__App.config.data.file__ is the path to the CSV to load. 

__App.config.data.columns__ is an array of objects which are fed to Datavore to create filters and values. Each one also has functions for creating the `now_showing` blurb.

__App.config.data.preprocessing_function__ affects the CSV before it's imported into the app.