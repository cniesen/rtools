
// NO JIRAS FOUND 
def fileName = args[0]
def fileDir;
def String noJiras = new File(fileName).text

// ExtEmailResultsDiff output
def extResultsDiffFile = fileName.substring(0, fileName.indexOf(".NoJiras")) + ".2" // .2 added as part of CiAnalysis.sh process
def extResultsDiffJiras = new File(extResultsDiffFile).text
def groupedErrors = extResultsDiffJiras.substring(extResultsDiffJiras.indexOf("New Failures Grouped by Error Message:") + 39, extResultsDiffJiras.indexOf("New Failures Details:"))
def testDetails = extResultsDiffJiras.substring(extResultsDiffJiras.indexOf("New Failures Details:"), extResultsDiffJiras.length()) + "\n\nTest:" // add token at end for easier matching

// Properties
def jenkinsBase = "http://ci.kuali.org"
def buildNumber = fileName.substring(fileName.lastIndexOf("-") + 1, fileName.indexOf(".json"))
def job = fileName
if (job.contains("/")) {
    job = job.substring(job.lastIndexOf("/") + 1, fileName.indexOf("-" + buildNumber + ".json"))
    fileDir = fileName.substring(0, fileName.lastIndexOf("/") + 1)
} else if (job.contains("\\")) {
    job = job.substring(job.lastIndexOf("\\") + 1, fileName.indexOf("-" + buildNumber + ".json"))
    fileDir = fileName.substring(0, fileName.lastIndexOf("\\") + 1)
} else {
    job = job.substring(0, fileName.indexOf("-" + buildNumber + ".json"))
    fileDir = ""
}

// TODO bundle test failures by errors....
while (noJiras.contains("NO JIRA FOUND")) {
    def test = noJiras.substring(0, noJiras.indexOf("NO JIRA FOUND")).trim()
    noJiras = noJiras.substring(noJiras.indexOf("NO JIRA FOUND") + 13, noJiras.length())

    // get error for jira, there can only be 1 match
/*
    def regex = ".*(${test}).*"
println(regex)
    def errorGroup = groupedErrors =~ /regex/
    def errorMessage = errorGroup[0] =~ /Error Message:.(.*)[\n]/
    println("${test} error message ${errorMessage}[0]")

System.exit(1) 
*/
    // get statck trace for jira, there can only be 1 match
//	def stackTrace = testDetails =~ /.*(\nTest:.test.*)[\n\n].*Test:.*/
//	println("${stackTrace}[0]")

    def testDetail = testDetails.substring(testDetails.indexOf("\nTest: " + test) + 7, testDetails.length())
    testDetail = testDetail.substring(0, testDetail.indexOf("\nTest:")).trim()
    def testError = ""
    try {
        testError = testDetail.substring(testDetail.indexOf("Error Message: ") + 15, testDetail.indexOf("Stack Trace:")).trim()
        if (testError.equals("")) {
            testError = "See Test Detail"
        }
    } catch (IndexOutOfBoundsException ioobe) {
        System.out.println(ioobe)
        testError = "Not determined"
    }

    def testSince = ""
    try {
        testSince = testDetail.substring(testDetail.indexOf("Failed Since:") + 13, testDetail.indexOf("Error Message:")).trim()
    } catch (IndexOutOfBoundsException ioobe) {
        System.out.println(ioobe)
        testSince = "-1"
    }

    def aftSteps = "";
    try {
        def aftStepsChunk = testDetail.substring(testDetail.indexOf("Standard Output: "), testDetail.length());
        while (aftStepsChunk.contains("AFT Step:")) {
            aftStepsChunk = aftStepsChunk.substring(aftStepsChunk.indexOf("AFT Step:"), aftStepsChunk.length())
            aftSteps = aftSteps + aftStepsChunk.substring(0, aftStepsChunk.indexOf("\n") + 1)
            aftStepsChunk = aftStepsChunk.substring(aftStepsChunk.indexOf("\n"), aftStepsChunk.length())
        }
    } catch (IndexOutOfBoundsException ioobe) {
        aftSteps = "Not determined"
    }

    def lastUrl = ""
    if (testDetail.indexOf("Last AFT URL: ") > -1) {
        lastUrl = " Last AFT URL: " + testDetail.substring(testDetail.indexOf("Last AFT URL: ") + 14, testDetail.length())
    }

    if (testDetail.indexOf("Standard Output:") < 0) {
        testDetail = testDetail.substring(testDetail.indexOf("Stack Trace:") + 12, testDetail.length()).trim()
    } else {
        testDetail = testDetail.substring(testDetail.indexOf("Stack Trace:") + 12, testDetail.indexOf("Standard Output:")).trim()
    }

//    testDetail = testDetail.substring(testDetail.indexOf("Stack Trace:") + 12, testDetail.length()).trim()
//    println(test + " " + testDetail)
    

    // use short name of test in summary
    def testCopy = test
    def testMethod = testCopy.substring(testCopy.lastIndexOf(".") + 1, testCopy.length()).trim()
    testCopy = testCopy.substring(0, testCopy.lastIndexOf("."))
    def testPackage = testCopy.substring(0, testCopy.lastIndexOf(".")).trim()
    def testClass = testCopy.substring(testCopy.lastIndexOf(".") + 1, testCopy.length()).trim()
    def testShort = testClass + "." + testMethod

    // url to test results
    def testResultsUrl = jenkinsBase + "/job/" + job + "/lastCompletedBuild/testReport/" + testPackage + "/" + testClass + "/" + testMethod + "/"

    // url to change set https://ci.kuali.org/view/rice/view/2.5/view/test-release/job/rice-2.5-test-functional-env14-jenkins-krad-sampleapp/190/changes
    def testSinceUrl = jenkinsBase + "/job/" + job + "/" + testSince + "/changes"

    // mvn command to run this test locally

    // use long name in description
    def description = ""

    def jira = aftSteps + lastUrl + "\n\nChange set for failure: " + testSinceUrl + "\nAbbreviated test name: " + testShort + "\nFull test name: " + test + "\nTest results url: " + testResultsUrl + "\nError Message: " + testError + "\n\n{code}Test Details: " + testDetail + "{code}"
   jira = jira.trim() + "\n\n";
    
    if (!testError.contains("KULRICE")) { // TODO These should be here, why wasn't the Jira found during by test name?
        def outputFile = fileDir + job + "-" + buildNumber + "-" + testShort + ".jira"
        def fw= new FileWriter(outputFile)
        fw.append(jira)
        fw.flush()
        fw.close()
    } else {
        def outputFile = fileDir + job + "-" + buildNumber + "-" + testShort + ".KULRICE"
        def fw= new FileWriter(outputFile)
        fw.append(jira)
        fw.flush()
        fw.close()
    }    
}
