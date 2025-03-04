# Deploy DACPAC using Liquibase

This repository demonstrates how to deploy MS SQL Server's DACPAC files using Liquibase

## Prerequisites

* Download and install `sqlpackage` ([Link](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver16))

## Liquibase Setup

DACPAC file are deployed using the [executeCommand](https://docs.liquibase.com/change-types/execute-command.html) change type which uses the abovementioned `sqlpackage` executable from Microsoft. 

Example changeset:

```xml
<changeSet author="amalik"  id="NPT_DEV.dacpac">  
    <executeCommand  executable="scripts/deployDacPac.sh"  
            timeout="300s">  
        <arg value="scripts/exports.sh"/>
        <arg value="param2_not_used"/>
    </executeCommand>
```

The `sqlpackage` command is used in the `scripts/deployDacPac.sh` script as follows. 

```sh
sqlpackage \
    /SourceFile:"<filename>.dacpac" \
    /Action:Publish \
    /TargetServerName:"<hostname>" \
    /TargetTrustServerCertificate:true \
    /TargetDatabaseName:"<database_name>" \
    /TargetUser:"<username>" \
    /TargetPassword:"<password>"
```

This shell script should be configured as executable (`chmod +x runDacPac.sh`) and you should be able to run this script standalone.

## Developer Experience

For developers wanting to deploy their DACPAC files using Liquibase, they will need to provide the DACPAC file name in the [exports.sh](scripts/exports.sh) file, along with other information such as the server name, database, username and password.

If implementing with CICD tools, you may want to use these Liquibase environment variables for username and password in your [exports.sh](scripts/exports.sh) script:
* `LIQUIBASE_COMMAND_USERNAME`
* `LIQUIBASE_COMMAND_PASSWORD`

Also note that Liquibase environment variable `LIQUIBASE_COMMAND_URL` is not compatible with `SQL_HOSTNAME` environment variable which is used in `/TargetServerName` argument of `sqlpackage`. As a result, you will need to specify SQL_HOSTNAME separately in addition to providing `LIQUIBASE_COMMAND_URL`. 

## Deploy using Liquibase

To run this script with Liquibase:

1. Provide your database connections (see [liquibase.properties](liquibase.properties) file). 
1. Using Liquibase Pro:
    1. Run `liquibase flow --flow-file=automation/dacpac-checks.flowfile.yaml`
    1. Run `liquibase flow --flow-file=automation/dacpac-deploy.flowfile.yaml`
1. Using Liquibase OSS:
    1. Run `liquibase update` command (Note: you will not be able to run Liquibase Policy Checks or Liquibase Flow siles without a Pro license)

----

## Explanation of files in this repository

```log
├── NPT_DEV.dacpac
├── README.md
├── changelog.xml
├── liquibase.properties
├── sqlpackage_commands.txt
├── scripts
│   ├── exports.sh
│   ├── generateUpdateScripts.sh
│   └── deployDacPac.sh
└── automation
    ├── dacpac-checks.flowfile.yaml
    ├── liquibase.checks-settings.conf
    └── dacpac-deploy.flowfile.yaml
```

1. `NPT_DEV.dacpac`: Sample dacpac file used in this repository
1. `changelog.xml`: This is the Liquibase changelog file demonstrating the use of `executeCommand` change type. 
1. `liquibase.properties`: Liquibase defaults file used to pass properties such as database URL, username, passwords, etc. These properties can also be passed using Liquibase environment variables in CICD. Each environment variable is shown as comments inside this file.
1. `sqlpackage_commands.txt`: This is a helper file to show basic `sqlpackage` commands used in this repository for various actions (Extract, Script and Publish)
 `scripts.generateUpdateScripts.sh`: This script is used to generate SQL scripts based on the provided dacpac and target database.
1. `scripts/exports.sh`: This script is where user would specify target database information as well as the name of the dacpac file.
1. `scripts/deployDacPac.sh`: This script updates the target database with the provided dacpac.
1. `automation/dacpac-checks.flowfile.yaml`: Liquibase flow file running Policy Checks. 
    1. This flow file executes `sqlpackage` with Action:Script to generate SQL. This SQL is tested against Policy Checks.
1. `automation/liquibase.checks-settings.conf`: This is the checks settings file for Liquibase Policy Checks. This file can be configured with any number of checks that can be run to pass/fail the dacpac-generated-script.
1. `automation/dacpac-deploy.flowfile.yaml`: Liquibase flow file applying the dacpac update.
