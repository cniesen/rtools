stime=$(date '+%s')
export DTS=$(date +%Y%m%d%H%M)
export RESULTS_DIR=rice-2.5-aft-krad-$DTS

export AFT_DIR=$(pwd)

# mvnLinks
export rDir=${PWD##*/}
# if repository/r/org/kauli is a file, not a directory, then assume we are in mvnLinks mode
if [ -f "/java/m2/r/org/kuali" ]; then
  export M2_REPO=/java/m2/$rDir
  export MVN_M2_REPO=-Dmaven.repo.local=$M2_REPO
fi

echo "cd rice-tools-test && mvn failsafe:integration-test -Pstests -Dmaven.failsafe.skip=false -Dit.test=JenkinsLastCompletedBuildNumber -Dcas.username=$1 -Dcas.password=$2 -Djenkins.jobs=rice-2.5-test-functional-env14-jenkins-krad-sampleapp -Dremote.driver.dontTearDownOnFailure=y $MVN_M2_REPO > ../rice-2.5-aft-krad-last.txt"
cd rice-tools-test && mvn failsafe:integration-test -Pstests -Dmaven.failsafe.skip=false -Dit.test=JenkinsLastCompletedBuildNumber -Dcas.username=$1 -Dcas.password=$2 -Djenkins.jobs=rice-2.5-test-functional-env14-jenkins-krad-sampleapp -Dremote.driver.dontTearDownOnFailure=y $MVN_M2_REPO > ../rice-2.5-aft-krad-last.txt

cd ..

JOBS=$(grep rice-2.5-test-functional-env14-jenkins-krad-sampleapp: rice-2.5-aft-krad-last.txt)

mkdir -p $RESULTS_DIR
cd $RESULTS_DIR
export FULL_RESULTS_DIR=$(pwd)

cd ..

CiJenkinsResultsFor.sh $1 $2 $FULL_RESULTS_DIR $JOBS

CiAnalysis.sh $FULL_RESULTS_DIR 

CiAftLocalKrad.sh $FULL_RESULTS_DIR $AFT_DIR

CiAftLocalCleanup.sh $FULL_RESULTS_DIR

