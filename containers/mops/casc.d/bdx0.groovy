organizationFolder('bdx0\'s repo') {
    organizations {
        github {
            scanCredentialsId('github-bdx0-jenkins-token')
            repoOwner('bdx0')
        }
    }
    // "Orphaned Item Strategy"
    orphanedItemStrategy {
        discardOldItems {
            daysToKeep(-1)
            numToKeep(-1)
        }
    }
    projectFactories {
        workflowMultiBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
    properties {
        noTriggerOrganizationFolderProperty {
            branches('.*')
        }
    }
    // Health Metrics
    configure { node ->
        node / healthMetrics / 'com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric' {
            nonRecursive(false)
        }
    }

    // Project filters
    configure { node ->
        def traits = node / navigators / 'org.jenkinsci.plugins.github__branch__source.GitHubSCMNavigator' / traits
        // traits << "jenkins.scm.impl.trait.RegexSCMSourceFilterTrait" {
        //     regex("${JENKINS_PROJECTS_REGEX_FILTER:-*}")
        // }
        traits << 'org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait' {
            strategyId('3')
        }
        traits << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
            strategyId('1')
        }
        traits << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
            strategyId('1')
            trust(class: 'org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait$TrustPermission')
        }
    }
    configure { node ->
        def templates = node / 'properties' / 'jenkins.branch.OrganizationChildTriggersProperty' / templates
        templates << 'com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger' {
            spec('* * * * *')
            interval('60m')
        }
    }

    // "Scan Organization Folder Triggers" : 1 day
    // We need to configure this stuff by hand because JobDSL only allow 'periodic(int min)' for now
    configure { node ->
        node / triggers / 'com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger' {
            spec('H/5 * * * *')
            interval(2 * 24 * 60 * 60 * 1000)
        }
    }
}