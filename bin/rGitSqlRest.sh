export R_HOME=.
mkdir -p $R_HOME/rtools/bin
mkdir $R_HOME/rtools/etc
cd $R_HOME/rtools/bin
wget https://raw.github.com/eghm/rtools/master/bin/rSqlRest.sh
chmod 755 rSqlRest.sh
wget https://raw.github.com/eghm/rtools/master/bin/rSqlRestInstall.sh
chmod 755 rSqlRestInstall.sh
cd $R_HOME/rtools/etc
wget https://raw.github.com/eghm/rtools/master/etc/sqlrestconf.xml
cd $R_HOME
rSqlRest.sh 



