import groovy.yaml.*
 
def configYaml = '''\
pipelines:
  - name: My Pipeline
    project: Default
    stages:
      - name: QA
        tasks:
          - name: Run test
            type: command
            command: echo testing...
      - name: UAT
        gates:
          - name: QA approval
            approvers:
              - qa
                glen@example.com
'''

def config = new YamlSlurper().parseText(configYaml)

String dsl=""

config.pipelines.each { pipeline ->
  dsl += "pipeline \"${pipeline.name}\", projectName: \"${pipeline.project}\"" + ',{\n'
  pipeline.stages.each { stage ->
  	dsl += "\n\tstage \"${stage.name}\"" + ',{\n'
    stage.gates.each { gate ->
      dsl += "\n\t\tgate \"${gate.name}\"" + ',{\n'
      dsl += '\n\t\t}'
    }  	
    stage.tasks.each { task ->
      dsl += "\n\t\ttask \"${task.name}\"" + ',{\n'
      dsl += '\n\t\t}'
    }
    dsl += '\n\t}'
  }
  dsl += '\n}'
}

dsl
