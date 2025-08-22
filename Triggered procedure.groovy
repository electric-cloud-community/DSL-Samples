serviceAccount 'serviceA'
project 'SharedServices', {
	procedure 'Triggered procedure', {
	  trigger 'GroupA Repo', {
		pluginKey = 'EC-Webhook'
		pluginParameter = [
			'alwaysRun': 'false',
			'checkClosure': '''\
				{
					headers, webhookPayloadBody ->
					return [
						launchWebhook: true,
						responseMessage: "Launching trigger for event \'push\' in branch \'main\'",
					]
				}'''.stripIndent(),
		]
		serviceAccountName = 'serviceA'
		triggerType = 'webhook'
		webhookName = 'default'
	  }
	}
}
def hostname="localhost"
"curl -k -d '{}' https://${hostname}/commander/link/webhookServerRequest?tokenId=" + getAccessTokens('serviceA')[0].trigger.accessTokenPublicId
