# $1 SERVER $2 JM_NUM $3 JM_LOOP $4 JM_RAMP
# RUN JMETER and have test and outputs in the directory this is run from
if [ -z "$1" ]
then
    echo "Required parameter, server"
    exit;
fi
export SERVER="$1"

if [ -z "$R_HOME" ]
then
    echo -e \n"Required env var R_HOME not set."
    exit;
fi

if [ ! -e testparams.txt ]
then
    if [ -z "$2" ]
    then
        echo -e "\nRequired parameter, threads (users) missing"
        exit;
    fi
    if [ -z "$3" ]
    then
        echo -e "\nRequired parameter, loops missing"
        exit;
    fi
    if [ -z "$4" ]
    then
        echo -e "\nRequired parameter, rampseconds missing"
        exit;
    fi

    echo "$2 users x $3 ramped up in $4 seconds" > testparams.txt
fi

if [ ! -e testparams.txt ]
then
    echo -e "\ntestparams.txt does not exist.  Exiting."
    exit;
fi

# get the release and build from the given server
# TODO it would probably be better if we got this when we get the env.jsp
wget http://$SERVER/portal.do -O portal.html
if [ -s portal.html ]
then
    echo "Sampleapp portal detected"
    grep "class=\"build\"" portal.html > version.xml
    # version_dirty.txt has a space before and after the build
    cut -f 3 -d : version.xml > version_dirty.txt
    export DIRTY_VERSION=$(cat version_dirty.txt)
    export R_VERSION=${DIRTY_VERSION/ /}
    echo $R_VERSION > version.txt
    rm version.xml
    rm version_dirty.txt
    # now get the release from version.txt
    cut -f 1 -d - version.txt > release.txt
else
    echo "Sampleapp portal 404 tring KRAD sampleapp"
    wget http://$SERVER/kr-krad/kradsampleapp?viewId=KradSampleAppHome -O portal.html
    echo "2.3.0" > release.txt
fi

if [ ! -e portal.html ]
then
    echo -e "\nportal.html does not exist!  Tomcat probably down or Dumping Memory!  Exiting"
    exit
fi

export R_RELEASE=$(cat release.txt)
echo $R_RELEASE

# dts.txt doesn't exist since the loadtest log mv script (needs to be done before the wget of the logs) deletes it.....
#scp tomcat@$SERVER:dts.txt .
if [ -e dts.txt ]
then
    export DTS=$(cat dts.txt)
fi

if [ -z "$DTS" ]
then
    echo -e "\nRequired variable, DTS"
    exit;
fi

wget -r --no-parent -nH --cut-dirs=2 -R index.html http://$SERVER/tomcat/logs/$DTS/
if [ ! -d "$DTS" ]
then
    echo -e "\n$DTS directory does not exist!  Tomcat probably down or Dumping Memory!  Exiting"
    exit;
fi

$R_HOME/rtools/bin/loadtest/jmeterGraphs.sh $(pwd)

mv *.jtl $DTS/
mv *.pdf $DTS/
mv *.png $DTS/
mv *.log $DTS/
mv *.txt $DTS/
mv *.out $DTS/
mv *.html $DTS/
mv *.jmx $DTS/
mv *.hprof $DTS/

cd $DTS

echo "run post.sh once screen shots have been copied to the DTS ( $DTS ) directory."
