/*

CloudBees CD/RO DSL: Create a dashboard with a number of reports showing pipeline start and complete status

ectool evalDsl --dslFile "pipelineStatsDashboard_v3.dsl"

*/

// Name of the project to create the "Pipeline Performance Stats" dashboard
// The project is created if it does not exist
def projName = 'System Performance Dashboards'

project projName, {

	report 'Average stages started by pipeline', {
		reportObjectTypeName = 'pipelinerun'
		reportQuery = '{"searchCriteria":[{"criterion":"MUST","conditions":[{"field":"reportEventType","operator":"EQUALS","value":"ef_pipeline_run_stage_started"}]}],"groupBy":[{"field":"flowRuntimeStateStart"},{"field":"pipelineId"},{"field":"pipelineName"}],"aggregationFunctions":[{"field":"reportEventType","function":"COUNT"}]}'
	  }

	  report 'Average tasks started by pipeline', {
		reportObjectTypeName = 'pipelinerun'
		reportQuery = '{"searchCriteria":[{"criterion":"MUST","conditions":[{"field":"reportEventType","operator":"EQUALS","value":"ef_pipeline_run_task_started"}]}],"groupBy":[{"field":"flowRuntimeStateStart"},{"field":"pipelineId"},{"field":"pipelineName"}],"aggregationFunctions":[{"field":"reportEventType","function":"COUNT"}]}'
	  }

	  report 'Number of gates started', {
		definition = '''{
	  "size": 0,
	  "query": {
		"bool": {
		  "filter": [
			{
			  "bool": {
				"should": [
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_gate_started",
						"boost": 1
					  }
					}
				  },
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_gate_completed",
						"boost": 1
					  }
					}
				  }
				],
				"adjust_pure_negative": true,
				"boost": 1
			  }
			}
		  ],
		  "adjust_pure_negative": true,
		  "boost": 1
		}
	  },
	  "aggregations": {
		"flowRuntimeStateStart": {
		  "date_histogram": {
			"field": "@timestamp",
			"format": "yyyy-MM-dd",
			"calendar_interval": "1d",
			"offset": 0,
			"order": {
			  "_key": "asc"
			},
			"keyed": false,
			"min_doc_count": 1
		  },
		  "aggregations": {
			"reportEventType": {
			  "terms": {
				"field": "reportEventType",
				"size": 10,
				"shard_size": 25,
				"min_doc_count": 1,
				"shard_min_doc_count": 0,
				"show_term_doc_count_error": false,
				"order": [
				  {
					"_count": "desc"
				  },
				  {
					"_key": "asc"
				  }
				]
			  }
			}
		  }
		}
	  }
	}'''
		reportObjectTypeName = 'pipelinerun'
	  }

	  report 'Number of pipelines started', {
		definition = '''{
	  "size": 0,
	  "query": {
		"bool": {
		  "filter": [
			{
			  "bool": {
				"should": [
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_started",
						"boost": 1
					  }
					}
				  },
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_completed",
						"boost": 1
					  }
					}
				  }
				],
				"adjust_pure_negative": true,
				"boost": 1
			  }
			}
		  ],
		  "adjust_pure_negative": true,
		  "boost": 1
		}
	  },
	  "aggregations": {
		"pipelineStartTime": {
		  "date_histogram": {
			"field": "@timestamp",
			"format": "yyyy-MM-dd",
			"calendar_interval": "1d",
			"offset": 0,
			"order": {
			  "_key": "asc"
			},
			"keyed": false,
			"min_doc_count": 1
		  },
		  "aggregations": {
			"reportEventType": {
			  "terms": {
				"field": "reportEventType",
				"size": 10,
				"shard_size": 25,
				"min_doc_count": 1,
				"shard_min_doc_count": 0,
				"show_term_doc_count_error": false,
				"order": [
				  {
					"_count": "desc"
				  },
				  {
					"_key": "asc"
				  }
				]
			  }
			}
		  }
		}
	  }
	}'''
		reportObjectTypeName = 'pipelinerun'
	  }

	  report 'Number of stages started', {
		definition = '''{
	  "size": 0,
	  "query": {
		"bool": {
		  "filter": [
			{
			  "bool": {
				"should": [
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_stage_started",
						"boost": 1
					  }
					}
				  },
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_stage_completed",
						"boost": 1
					  }
					}
				  }
				],
				"adjust_pure_negative": true,
				"boost": 1
			  }
			}
		  ],
		  "adjust_pure_negative": true,
		  "boost": 1
		}
	  },
	  "aggregations": {
		"stageStartTime": {
		  "date_histogram": {
			"field": "@timestamp",
			"format": "yyyy-MM-dd",
			"calendar_interval": "1d",
			"offset": 0,
			"order": {
			  "_key": "asc"
			},
			"keyed": false,
			"min_doc_count": 1
		  },
		  "aggregations": {
			"reportEventType": {
			  "terms": {
				"field": "reportEventType",
				"size": 10,
				"shard_size": 25,
				"min_doc_count": 1,
				"shard_min_doc_count": 0,
				"show_term_doc_count_error": false,
				"order": [
				  {
					"_count": "desc"
				  },
				  {
					"_key": "asc"
				  }
				]
			  }
			}
		  }
		}
	  }
	}'''
		reportObjectTypeName = 'pipelinerun'
	  }

	  report 'Number of tasks started', {
		definition = '''{
	  "size": 0,
	  "query": {
		"bool": {
		  "filter": [
			{
			  "bool": {
				"should": [
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_task_started",
						"boost": 1
					  }
					}
				  },
				  {
					"term": {
					  "reportEventType": {
						"value": "ef_pipeline_run_task_completed",
						"boost": 1
					  }
					}
				  }
				],
				"adjust_pure_negative": true,
				"boost": 1
			  }
			}
		  ],
		  "adjust_pure_negative": true,
		  "boost": 1
		}
	  },
	  "aggregations": {
		"taskStartTime": {
		  "date_histogram": {
			"field": "@timestamp",
			"format": "yyyy-MM-dd",
			"calendar_interval": "1d",
			"offset": 0,
			"order": {
			  "_key": "asc"
			},
			"keyed": false,
			"min_doc_count": 1
		  },
		  "aggregations": {
			"reportEventType": {
			  "terms": {
				"field": "reportEventType",
				"size": 10,
				"shard_size": 25,
				"min_doc_count": 1,
				"shard_min_doc_count": 0,
				"show_term_doc_count_error": false,
				"order": [
				  {
					"_count": "desc"
				  },
				  {
					"_key": "asc"
				  }
				]
			  }
			}
		  }
		}
	  }
	}'''
		reportObjectTypeName = 'pipelinerun'
	  }

	  report 'Pipeline duration', {
		reportObjectTypeName = 'pipelinerun'
		reportQuery = '{"searchCriteria":[{"criterion":"MUST","conditions":[{"field":"reportEventType","operator":"EQUALS","value":"ef_pipeline_run_completed"}]}],"groupBy":[{"field":"flowRuntimeStart","name":"pipelineStartTime"}],"aggregationFunctions":[{"field":"elapsedTime","function":"AVERAGE"}]}'
	  }

	  report 'Stage duration', {
		reportObjectTypeName = 'pipelinerun'
		reportQuery = '{"searchCriteria":[{"criterion":"SHOULD","conditions":[{"field":"reportEventType","operator":"EQUALS","value":"ef_pipeline_run_stage_completed"}]}],"groupBy":[{"field":"flowRuntimeStateStart","name":"stageStartTime"}],"aggregationFunctions":[{"field":"flowRuntimeStateElapsedTime","function":"AVERAGE"}]}'
	  }

	  report 'Task duration', {
		reportObjectTypeName = 'pipelinerun'
		reportQuery = '{"searchCriteria":[{"criterion":"SHOULD","conditions":[{"field":"reportEventType","operator":"EQUALS","value":"ef_pipeline_run_task_completed"}]}],"groupBy":[{"field":"flowRuntimeStateStart","name":"taskStartTime"}],"aggregationFunctions":[{"field":"flowRuntimeStateElapsedTime","function":"AVERAGE"}]}'
	  }

	dashboard 'Pipeline Performance Stats', {
		layout = 'FLOW'
		type = 'STANDARD'

		reportingFilter 'DateFilter', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'BETWEEN'
		  orderIndex = '0'
		  parameterName = '@timestamp'
		  required = '1'
		  type = 'DATE'
		}

		reportingFilter 'ProjectFilter', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'IN'
		  orderIndex = '1'
		  type = 'PROJECT'
		}

		reportingFilter 'Pipeline Name', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'IN'
		  orderIndex = '2'
		  parameterName = 'pipelineName'
		  reportObjectTypeName = 'pipelinerun'
		  type = 'CUSTOM'
		}

		reportingFilter 'TagFilter', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'IN'
		  orderIndex = '3'
		  parameterName = 'tags'
		  type = 'TAG'
		}

		widget 'Pipelines started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'pipelineStartTime_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_completed': '#99cc00',
			'ef_pipeline_run_started': '#0099cc',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  linkTarget = 'Pipeline Runs'
		  orderIndex = '1'
		  reportName = 'Number of pipelines started'
		  reportProjectName = projName
		  title = 'Pipelines started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Stages started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'stageStartTime_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_stage_completed': '#99cc00',
			'ef_pipeline_run_stage_started': '#0099cc',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '2'
		  reportName = 'Number of stages started'
		  reportProjectName = projName
		  title = 'Stages started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Tasks started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'taskStartTime_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_task_completed': '#99cc00',
			'ef_pipeline_run_task_started': '#0099cc',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '3'
		  reportName = 'Number of tasks started'
		  reportProjectName = projName
		  title = 'Tasks started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Gates started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'flowRuntimeStateStart_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_gate_started': '#0099cc',
			'ef_pipeline_run_gate_completed': '#99cc00',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '4'
		  reportName = 'Number of gates started'
		  reportProjectName = projName
		  title = 'Gates started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Average pipeline duration', {
		  attributeDataType = [
			'yAxis': 'DURATION',
			'xAxis': 'DATE',
		  ]
		  attributePath = [
			'yAxis': 'average_elapsedTime',
			'xAxis': 'pipelineStartTime_label',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '5'
		  reportName = 'Pipeline duration'
		  reportProjectName = projName
		  title = 'Average pipeline duration'
		  visualization = 'LINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'smoothedLine',
		  ]

		  widgetFilterOverride 'DateFilter', {
			dashboardName = 'Pipeline Performance Stats'
			ignoreFilter = '0'
			parameterName = 'flowRuntimeStart'
			widgetName = 'Average pipeline duration'
		  }
		}

		widget 'Average stage duration', {
		  attributeDataType = [
			'yAxis': 'DURATION',
			'xAxis': 'DATE',
		  ]
		  attributePath = [
			'yAxis': 'average_flowRuntimeStateElapsedTime',
			'xAxis': 'stageStartTime_label',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '6'
		  reportName = 'Stage duration'
		  reportProjectName = projName
		  title = 'Average stage duration'
		  visualization = 'LINE_CHART'

		  widgetFilterOverride 'DateFilter', {
			dashboardName = 'Pipeline Performance Stats'
			ignoreFilter = '0'
			parameterName = 'flowRuntimeStateStart'
			widgetName = 'Average stage duration'
		  }
		}

		widget 'Average task duration', {
		  attributeDataType = [
			'yAxis': 'DURATION',
			'xAxis': 'DATE',
		  ]
		  attributePath = [
			'yAxis': 'average_flowRuntimeStateElapsedTime',
			'xAxis': 'taskStartTime_label',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '7'
		  reportName = 'Task duration'
		  reportProjectName = projName
		  title = 'Average task duration'
		  visualization = 'LINE_CHART'

		  widgetFilterOverride 'DateFilter', {
			dashboardName = 'Pipeline Performance Stats'
			ignoreFilter = '0'
			parameterName = 'flowRuntimeStateStart'
			widgetName = 'Average task duration'
		  }
		}

		widget 'Average stages started by pipeline', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'stacks': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'count_reportEventType',
			'xAxis': 'flowRuntimeStateStart_label',
			'stacks': 'pipelineName',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '9'
		  reportName = 'Average stages started by pipeline'
		  reportProjectName = projName
		  title = 'Average stages started by pipeline'
		  visualization = 'STACKED_VERTICAL_BAR_CHART'
		}

		widget 'Average tasks started by pipeline', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'stacks': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'count_reportEventType',
			'xAxis': 'flowRuntimeStateStart_label',
			'stacks': 'pipelineName',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '10'
		  reportName = 'Average tasks started by pipeline'
		  reportProjectName = projName
		  title = 'Average tasks started by pipeline'
		  visualization = 'STACKED_VERTICAL_BAR_CHART'
		}
	}

	dashboard 'Pipeline Performance Stats', {
		layout = 'FLOW'
		type = 'STANDARD'

		reportingFilter 'DateFilter', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'BETWEEN'
		  orderIndex = '0'
		  parameterName = '@timestamp'
		  required = '1'
		  type = 'DATE'
		}

		reportingFilter 'ProjectFilter', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'IN'
		  orderIndex = '1'
		  type = 'PROJECT'
		}

		reportingFilter 'Pipeline Name', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'IN'
		  orderIndex = '2'
		  parameterName = 'pipelineName'
		  reportObjectTypeName = 'pipelinerun'
		  type = 'CUSTOM'
		}

		reportingFilter 'TagFilter', {
		  dashboardName = 'Pipeline Performance Stats'
		  operator = 'IN'
		  orderIndex = '3'
		  parameterName = 'tags'
		  type = 'TAG'
		}

		widget 'Pipelines started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'pipelineStartTime_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_completed': '#99cc00',
			'ef_pipeline_run_started': '#0099cc',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  linkTarget = 'Pipeline Runs'
		  orderIndex = '1'
		  reportName = 'Number of pipelines started'
		  reportProjectName = projName
		  title = 'Pipelines started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Stages started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'stageStartTime_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_stage_completed': '#99cc00',
			'ef_pipeline_run_stage_started': '#0099cc',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '2'
		  reportName = 'Number of stages started'
		  reportProjectName = projName
		  title = 'Stages started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Tasks started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'taskStartTime_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_task_completed': '#99cc00',
			'ef_pipeline_run_task_started': '#0099cc',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '3'
		  reportName = 'Number of tasks started'
		  reportProjectName = projName
		  title = 'Tasks started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Gates started vs. completed', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'series': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'reportEventType_count',
			'xAxis': 'flowRuntimeStateStart_label',
			'series': 'reportEventType',
		  ]
		  color = [
			'ef_pipeline_run_gate_started': '#0099cc',
			'ef_pipeline_run_gate_completed': '#99cc00',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '4'
		  reportName = 'Number of gates started'
		  reportProjectName = projName
		  title = 'Gates started vs. completed'
		  visualization = 'MULTILINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'straightLine',
		  ]
		}

		widget 'Average pipeline duration', {
		  attributeDataType = [
			'yAxis': 'DURATION',
			'xAxis': 'DATE',
		  ]
		  attributePath = [
			'yAxis': 'average_elapsedTime',
			'xAxis': 'pipelineStartTime_label',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '5'
		  reportName = 'Pipeline duration'
		  reportProjectName = projName
		  title = 'Average pipeline duration'
		  visualization = 'LINE_CHART'
		  visualizationProperty = [
			'lineStyle': 'smoothedLine',
		  ]

		  widgetFilterOverride 'DateFilter', {
			dashboardName = 'Pipeline Performance Stats'
			ignoreFilter = '0'
			parameterName = 'flowRuntimeStart'
			widgetName = 'Average pipeline duration'
		  }
		}

		widget 'Average stage duration', {
		  attributeDataType = [
			'yAxis': 'DURATION',
			'xAxis': 'DATE',
		  ]
		  attributePath = [
			'yAxis': 'average_flowRuntimeStateElapsedTime',
			'xAxis': 'stageStartTime_label',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '6'
		  reportName = 'Stage duration'
		  reportProjectName = projName
		  title = 'Average stage duration'
		  visualization = 'LINE_CHART'

		  widgetFilterOverride 'DateFilter', {
			dashboardName = 'Pipeline Performance Stats'
			ignoreFilter = '0'
			parameterName = 'flowRuntimeStateStart'
			widgetName = 'Average stage duration'
		  }
		}

		widget 'Average task duration', {
		  attributeDataType = [
			'yAxis': 'DURATION',
			'xAxis': 'DATE',
		  ]
		  attributePath = [
			'yAxis': 'average_flowRuntimeStateElapsedTime',
			'xAxis': 'taskStartTime_label',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '7'
		  reportName = 'Task duration'
		  reportProjectName = projName
		  title = 'Average task duration'
		  visualization = 'LINE_CHART'

		  widgetFilterOverride 'DateFilter', {
			dashboardName = 'Pipeline Performance Stats'
			ignoreFilter = '0'
			parameterName = 'flowRuntimeStateStart'
			widgetName = 'Average task duration'
		  }
		}

		widget 'Average stages started by pipeline', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'stacks': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'count_reportEventType',
			'xAxis': 'flowRuntimeStateStart_label',
			'stacks': 'pipelineName',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '9'
		  reportName = 'Average stages started by pipeline'
		  reportProjectName = projName
		  title = 'Average stages started by pipeline'
		  visualization = 'STACKED_VERTICAL_BAR_CHART'
		}

		widget 'Average tasks started by pipeline', {
		  attributeDataType = [
			'yAxis': 'NUMBER',
			'xAxis': 'DATE',
			'stacks': 'STRING',
		  ]
		  attributePath = [
			'yAxis': 'count_reportEventType',
			'xAxis': 'flowRuntimeStateStart_label',
			'stacks': 'pipelineName',
		  ]
		  dashboardName = 'Pipeline Performance Stats'
		  orderIndex = '10'
		  reportName = 'Average tasks started by pipeline'
		  reportProjectName = projName
		  title = 'Average tasks started by pipeline'
		  visualization = 'STACKED_VERTICAL_BAR_CHART'
		}
	}


	}

