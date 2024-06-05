import groovy.yaml.*
 
def configYaml = '''\
pipelines:
  - name: My Pipeline
    stages:
      - name: QA
        tasks:
          - name: Run test
            type: command
            command: echo testing...
      - name: UAT
        gate:
          - name: QA approval
            approvers:
              - qa
                glen@example.com
'''

def config = new YamlSlurper().parseText(configYaml)

config.pipelines
