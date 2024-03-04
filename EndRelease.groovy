/*

Pipeline that can run asynchrously in a Release to end the release and set the ACL to Deny everyone write and execute permissions. This ensures no one can alter the Properties of the Release after it is closed

*/

project 'CloudBees', {
  pipeline 'EndRelease', {
    projectName = 'CloudBees'

    formalParameter 'ReleaseName', defaultValue: '$[/myPipelineRuntime/releaseName]', {
      orderIndex = '1'
      required = '1'
      type = 'entry'
    }

    formalParameter 'RuntimeID', defaultValue: '$[/myPipelineRuntime/flowRuntimeId]', {
      orderIndex = '2'
      required = '1'
      type = 'entry'
    }

    formalParameter 'ReleaseProjectName', defaultValue: '$[/myPipelineRuntime/projectName]', {
      orderIndex = '3'
      required = '1'
      type = 'entry'
    }

    formalParameter 'ReleaseID', defaultValue: '$[/myPipelineRuntime/releaseId]', {
      orderIndex = '4'
      required = '1'
      type = 'entry'
    }

    formalParameter 'ec_stagesToRun', {
      expansionDeferred = '1'
    }

    stage 'EndRelease', {
      colorCode = '#289ce1'
      pipelineName = 'EndRelease'
      task 'EndRelease', {
        actualParameter = [
                'ReleaseID': '$[/myPipelineRuntime/ReleaseID]',
                'ReleaseName': '$[/myPipelineRuntime/ReleaseName]',
                'ReleaseProjectName': '$[/myPipelineRuntime/ReleaseProjectName]',
                'RuntimeID': '$[/myPipelineRuntime/RuntimeID]',
        ]
        subprocedure = 'EndRelease'
        subproject = 'CloudBees'
        taskType = 'PROCEDURE'
      }
    }

    // Custom properties

  }
  procedure 'EndRelease', {
    projectName = 'CloudBees'
    timeLimit = '0'
  
    formalParameter 'ReleaseProjectName', {
      orderIndex = '1'
      required = '1'
      type = 'entry'
    }
  
    formalParameter 'RuntimeID', {
      orderIndex = '2'
      required = '1'
      type = 'entry'
    }
  
    formalParameter 'ReleaseName', {
      orderIndex = '3'
      required = '1'
      type = 'entry'
    }
  
    formalParameter 'ReleaseID', {
      orderIndex = '4'
      required = '1'
      type = 'entry'
    }
  
    step 'End Release', {
      command = '''import com.electriccloud.client.groovy.ElectricFlow
  ElectricFlow ef = new ElectricFlow()
  // Specify the length of time to wait in seconds.
  int waitFor = 30;
  int retries = 10
  
  for ( int i = 0; i < retries; i++ ) {
      def result = ef.getPipelineRuntimeDetails(flowRuntimeIds: [\'$[/myJob/RuntimeID]\'])
      def completed = result.flowRuntime[0].completed
      println(result)
      if (completed == "1")
      {
          println(ef.completeRelease( projectName: "$[/myJob/ReleaseProjectName]", releaseName: "$[/myJob/ReleaseName]" ))
          System.exit(0)
      }
      println("Release has not completed yet.")
      Thread.sleep(waitFor * 1000);
  }
  
  println("Release did not complete withing the specified wait time.")
  System.exit(1)'''
      errorHandling = 'abortProcedureNow'
      procedureName = 'EndRelease'
      shell = 'ec-groovy'
      timeLimit = '0'
      timeLimitUnits = 'seconds'
    }
  
    step 'ModifyACL', {
      description = 'Deny Modify Permissions for Everyone'
      command = '''import com.electriccloud.client.groovy.ElectricFlow
  ElectricFlow ef = new ElectricFlow()
  ef.createAclEntry(objectId: "release-$[/myJob/ReleaseID]", principalType:"group",principalName:"Everyone",readPrivilege:"allow",modifyPrivilege:"deny",executePrivilege:"deny",changePermissionsPrivilege:"deny")'''
      errorHandling = 'abortProcedureNow'
      procedureName = 'EndRelease'
      shell = 'ec-groovy'
      timeLimit = '0'
      timeLimitUnits = 'seconds'
    }
  }
}
