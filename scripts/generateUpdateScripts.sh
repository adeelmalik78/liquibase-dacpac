echo exports=${1}
echo DACPAC_FILE=${2}

cat ${1}
source ${1}

# sudo spctl --master-disable

sqlpackage \
    /SourceFile:"${2}" \
    /Action:Script \
    /TargetServerName:"${SQL_TARGETSERVERNAME}" \
    /TargetTrustServerCertificate:true \
    /TargetDatabaseName:"${SQL_TARGETDATABASE}" \
    /TargetUser:"${SQL_TARGETUSERNAME}" \
    /TargetPassword:"${SQL_TARGETPASSWORD}" \
    /OutputPath:"output/outputScript.sql"

# sudo spctl --master-enable