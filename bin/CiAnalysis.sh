# Directory to put results in, CAS username, CAS password

#JenkinsResults.sh $2 $3 $1

cd $R_HOME/rtools/bin

touch ExtEmailBlank.txt 

for f in $1/*.json
do
	
	echo -e "\nprocessing $f"
   
    # transfor JSON file into ExtEmail like format which I already had a script parsing
    groovy CiJsonObj.groovy $f > $f.1

    # List test failures and errors and group tests by errors
    groovy ExtEmailResultsDiff.groovy ExtEmailBlank.txt $f.1 > $f.2

    # Identify existing (open) Jiras for failed tests flag those that don't have Jiras
    groovy ExtResultsJiras.groovy $f.2 > $f.out

    # Pull out failures with no jiras
    grep "NO JIRA FOUND" $f.out > $f.NoJiras   

    # Create Jira data
    groovy CiJiraData.groovy $f.NoJiras

    # Group Jira data based on Error Message
#    groovy CiJiraGroup.groovy $f

done

rm ExtEmailBlank.txt

./CiJiraGroup.sh $1