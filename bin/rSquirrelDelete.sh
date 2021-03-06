#!/bin/bash
cd $R_HOME/$1
export DBUI=$(cat .rdev/$1-$2-uid.txt)
export XMLSTAR=$(xml --version)
if [ -z "$XMLSTAR" ]
then
  echo "xmlstar not installed, unable to delete SQuirreLSQL aliases."
  exit
fi

export DBNAME=$1$2
export DBSERVER=$3
if [ -z "$3" ]
then
	export DBSERVER=localhost
fi
export DBPORT=$4
if [ -z "$4" ]
then
	export DBPORT=3306
fi

if [ ! -e ~/.squirrel-sql/SQLAliases23.xml.bak ]
then
	cp ~/.squirrel-sql/SQLAliases23.xml ~/.squirrel-sql/SQLAliases23.xml.bak
fi
if [ ! -e ~/.squirrel-sql/SQLAliases23_treeStructure.xml.bak ]
then
	cp ~/.squirrel-sql/SQLAliases23_treeStructure.xml ~/.squirrel-sql/SQLAliases23_treeStructure.xml.bak
fi

cat .rdev/$1-$2-uid.txt
#export DBUI=$(xml sel -t -m "/Beans/Bean/name[contains(text(), '$DBNAME')]" -v "concat(../identifier/string, '')" ~/.squirrel-sql/SQLAliases23.xml)

if [ -z "$BDUI" ]
then
	echo "No UID $BDUI in  ~/.squirrel-sql/SQLAliases23.xml containing DB $DBNAME no SQuirreLSQL alias to delete."
	exit
fi
echo "Deleting $DBUI for $DBSERVER:$DBPORT MySQL $DBNAME from ~/.squirrel-sql/SQLAliases23.xml and ~/.squirrel-sql/SQLAliases23_treeStructure.xml"
xml ed -d "//Bean/identifier/string[contains(text(), '$DBUI')]/../.."  ~/.squirrel-sql/SQLAliases23.xml > ~/.squirrel-sql/SQLAliases23.xml.del
mv ~/.squirrel-sql/SQLAliases23.xml.del ~/.squirrel-sql/SQLAliases23.xml
xml ed -d "//Bean/aliasIdentifier/string[contains(text(), '$DBUI')]/../.."  ~/.squirrel-sql/SQLAliases23_treeStructure.xml > ~/.squirrel-sql/SQLAliases23_treeStructure.xml.del
mv ~/.squirrel-sql/SQLAliases23_treeStructure.xml.del ~/.squirrel-sql/SQLAliases23_treeStructure.xml
