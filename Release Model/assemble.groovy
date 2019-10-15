/*
Format: Electric Flow DSL
File: assemble.groovy
Description: Top level DSL to create release and all dependencies

ectool evalDsl --dslFile "assemble.groovy"

*/

import groovy.json.JsonOutput

// def dslDir = "/home/lrochette/GitHub/DSL-Samples/Release Model/"
def dslDir = "/vagrant/DSL-Samples/Release Model/"
def projectName = "On line bank Release"
def artifactGroup = "com.mybank.apps"

// print date in yyyy-mm-dd format
def formatDate(d) {
	year = d.year+1900
	date = d.date
	month = d.month+1
	return "${year}-${month}-${date}"
}

def release = [
  name: "Quarterly Online Banking Release",
  plannedStartDate: (String) formatDate(new Date()),
  plannedEndDate: (String) formatDate(new Date()+14),
  pipeline: [
    name: "Quarterly Online Banking Release",
    stages: ["UAT", "PreProd", "PROD"]
  ],
  apps: [
	[name: "OB - Account Statements",
		version: "2.4", artifactKey: "statements",
		snapEnv: "Banking-DEV", envs: ["Banking-UAT", "Banking-PreProd", "Banking-PROD"] ],
	[name: "OB - Credit Card Accounts",
		version: "5.1", artifactKey: "cards",
		snapEnv: "Banking-DEV", envs: ["Banking-UAT", "Banking-PreProd", "Banking-PROD"]],
	[name: "OB - Fund Transfer",
		version: "1.7", artifactKey: "fund",
		snapEnv: "Banking-DEV", envs: ["Banking-UAT", "Banking-PreProd", "Banking-PROD"] ]
	]
]

def applications = []
def artifacts = []

project projectName, {

  ec_tags="DSL"         // to isolate project more easily
	procedure "UpdateTicket"
	procedure "SeleniumTests"

	procedure "Create Application",{
		formalParameter "projName", required: "1"
		formalParameter "appName", required: "1"
		formalParameter "version", required: "1"
		formalParameter "artifactGroup", required: "1"
		formalParameter "artifactKey", required: "1"
		formalParameter "envs", required: "1"
		formalParameter "snapEnv", required: "1"
		formalParameter "runAppCreation", required: "1"

	step "Create Installer sh",
	  subproject : "/plugins/EC-FileOps/project",
	  subprocedure : "AddTextToFile",
	  actualParameter : [
		AddNewLine: "1",
		Append: "1",
		Content: "echo installing \$[appName]",  // required
		Path: "installer.sh",  // required
	  ]
	step "Create Installer bat",
	  subproject : "/plugins/EC-FileOps/project",
	  subprocedure : "AddTextToFile",
	  actualParameter : [
		AddNewLine: "1",
		Append: "1",
		Content: "echo installing \$[appName]",  // required
		Path: "installer.bat",  // required
	  ]
	  step "Create Artifact",
	  subproject : "/plugins/EC-Artifact/project",
	  subprocedure : "Publish",
	  actualParameter : [
		artifactName: "\$[artifactGroup]:\$[artifactKey]",  // required
		artifactVersionVersion: "\$[version]-\$[/increment /server/ec_counters/jobCounter]",  // required
		fromLocation: ".",
		includePatterns: "installer.*",
		repositoryName: "default",  // required
	  ]
	step "Generate Application", condition: '$[runAppCreation]',
			command: new File(dslDir + "createAppModel.groovy").text,
			shell: "ectool evalDsl --dslFile {0}"
	step "Deploy to snapshot environment",
		command: "ectool runProcess \"\$[projName]\" \"\$[appName]\" Deploy --environmentName \"\$[snapEnv]\" --actualParameter \"ErrorLevel=INFO\""
	step "Wait for deploy", command: "sleep 10", shell: "ec-perl"
	step "Create snapshot",
		command: "ectool createSnapshot \"\$[projName]\" \"\$[appName]\" \"\$[version]\" --environmentName \"\$[snapEnv]\"",
			errorHandling: "ignore"
	}

	procedure "Create Pipeline",{
		formalParameter "projName", required: "1"
		formalParameter "stages", required: "1"
		formalParameter "release", required: "1"

		step "Generate Pipeline",
			command: new File(dslDir + "createPipeline.groovy").text,
			shell: "ectool evalDsl --dslFile {0}"
	}

	procedure "Create Release",{
		formalParameter "projName", required: "1"
		formalParameter "release", required: "1"
		formalParameter "pipeName", required: "1"
		formalParameter "applications", required: "1"
		formalParameter "versions", required: "1"
		formalParameter "stages", required: "1"
		formalParameter "plannedStartDate", required: "1", description: "yyyy-mm-dd format"
		formalParameter "plannedEndDate", required: "1", description: "yyyy-mm-dd format"

		step "Generate Release",
			command: new File(dslDir + "createRelease.groovy").text,
			shell: "ectool evalDsl --dslFile {0}"

	}

	procedure "Assemble",{

		step "Open Permissions",
		shell: "ectool evalDsl --dslFile {0}",
		command: """\
			aclEntry principalName : 'project: $projectName',
				principalType : 'user',
				systemObjectName : 'server',
				changePermissionsPrivilege : 'allow',
				executePrivilege : 'allow',
				modifyPrivilege : 'allow',
				readPrivilege : 'allow',
				objectType: 'server'
			property '/jobs/\$[/myJob]/aclEntry', value: 'project: $projectName'
		""".stripIndent()

		// Create Application and Environment Models
		release.apps.each { app ->
			applications.push(app.name)
			artifacts.push("$artifactGroup:$app.artifactKey")
			step "Generate Application - $app.name",
				subproject : projectName,
				subprocedure : "Create Application",
				actualParameter : [
					projName: projectName,
					appName: app.name,  // required
					version: app.version,
					artifactGroup: artifactGroup,
					artifactKey: (String) app.artifactKey,
					envs: (String) app.envs.join(",")+","+app.snapEnv,
					snapEnv: app.snapEnv,
					runAppCreation:"1"
				],
				parallel: "false"
		}

		// Create Pipeline
		step "Create Pipeline",
			subproject : projectName,
			subprocedure : "Create Pipeline",
			actualParameter : [
				projName: projectName,
				stages: release.pipeline.stages.join(","),
				release: release.name
			]

		step "Create Release",
			subproject : projectName,
			subprocedure : "Create Release",
			actualParameter : [
				projName: projectName,
				release: release.name,
                pipeName: release.pipeline.name,
				applications: release.apps.name.join(","),
				versions: release.apps.version.join(","),
				stages: release.pipeline.stages.join(","),
				plannedStartDate: release.plannedStartDate,
				plannedEndDate: release.plannedEndDate
			]

		step "Write out properties",
			command: "" +
				'property "/jobs/$[/myJob]/projName", value: "' + projectName + "\"\n" +
				'property "/jobs/$[/myJob]/release", value: ' + JsonOutput.toJson(release.name) + "\n" +
				'property "/jobs/$[/myJob]/pipeline", value: ' + JsonOutput.toJson(release.name) + "\n" +
				'property "/jobs/$[/myJob]/applications", value: \'' + JsonOutput.toJson(applications) + "\'\n" +
				'property "/jobs/$[/myJob]/artifacts", value: \'' + JsonOutput.toJson(artifacts) + "\'\n",
			shell: "ectool evalDsl --dslFile {0}"

/*				ectool setProperty /myJob/release \"$release.name\"
				ectool setProperty /myJob/pipeline \"$release.name\"
			""".stripIndent(),
				"ectool setProperty /myJob/applications \'" + JsonOutput.toJson(applications) + "\'\n" +
				"ectool setProperty /myJob/artifacts \'" + JsonOutput.toJson(artifacts) + "\'\n"
*/
		step "Create Clean Procedure",
			command: new File(dslDir + "clean.groovy").text,
			shell: "ectool evalDsl --dslFile {0}"
	}

}

//transaction {runProcedure projectName: "On line bank Release", procedureName: "Assemble"}
