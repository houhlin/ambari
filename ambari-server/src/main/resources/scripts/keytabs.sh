#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

usage () {
echo "Usage: keytabs.sh <HOST_PRINCIPAL_KEYTABLE.csv> ";
echo "  <HOST_PRINCIPAL_KEYTABLE.csv>: CSV file generated by 'Enable Security Wizard' of Ambari";
exit 1;
}

###################
## processCSVFile()
###################
processCSVFile () {
    csvFile=$1;
    echo "#!/bin/bash"
    echo "###########################################################################"
    echo "###########################################################################"
    echo "## "
    echo "## Ambari Security Script Generator"
    echo "## "
    echo "## Ambari security script is generated which should be run on the" 
    echo "## Kerberos server machine."
    echo "## "
    echo "## Running the generated script will create host specific keytabs folders."
    echo "## Each of those folders will contain service specific keytab files with "
    echo "## appropriate permissions. There folders should be copied as the appropriate"
    echo "## host's '/etc/security/keytabs' folder"
    echo "###########################################################################"
    echo "###########################################################################"
    
    rm -f commands.mkdir;
    rm -f commands.chmod;
    rm -f commands.addprinc;
    rm -f commands.xst
    rm -f commands.xst.cp
    rm -f commands.chown.1
    rm -f commands.chmod.1
    rm -f commands.chmod.2
    rm -f commands.tar
    
    seenHosts="";
    seenPrincipals="";
    
    GROUP_HADOOP="hadoop"
    USER_HDFS="hdfs";
    USER_HBASE="hbase";
    USER_MAPRED="mapred";
    USER_SMOKE="ambari-qa";
    USER_ZK="zookeeper";
    USER_OOZIE="oozie";
    USER_HIVE="hive";
    USER_NAGIOS="nagios";
    
    echo "mkdir -p ./tmp_keytabs" >> commands.mkdir;
    cat $csvFile | while read line; do
        hostName=`echo $line|cut -d , -f 1`;
        service=`echo $line|cut -d , -f 2`;
        principal=`echo $line|cut -d , -f 3`;
        keytabFile=`echo $line|cut -d , -f 4`;
        
        if [[ $seenHosts != *$hostName* ]]; then
              echo "mkdir -p ./keytabs_$hostName" >> commands.mkdir;
              echo "chmod 755 ./keytabs_$hostName" >> commands.chmod;
              echo "chown -R root:$GROUP_HADOOP `pwd`/keytabs_$hostName" >> commands.chown.1
              echo "mkdir -p `pwd`/tmp_tar/etc/security/" >> commands.tar
              echo "mv  `pwd`/keytabs_$hostName `pwd`/tmp_tar/etc/security/keytabs" >> commands.tar
              echo "tar -C `pwd`/tmp_tar/ -cf `pwd`/keytabs_$hostName.tar etc" >> commands.tar
              echo "rm -rf `pwd`/tmp_tar" >> commands.tar
              seenHosts="$seenHosts$hostName";
        fi
        
        if [[ $seenPrincipals != *$principal* ]]; then
          echo -e "kadmin.local -q \"addprinc -randkey $principal\"" >> commands.addprinc;
          seenPrincipals="$seenPrincipals$principal"
        fi
        
        tmpKeytabFile=${keytabFile/\/etc\/security\/keytabs/`pwd`/tmp_keytabs}
        newKeytabFile=${keytabFile/\/etc\/security\/keytabs/`pwd`/keytabs_$hostName}
        if [ ! -f $tmpKeytabFile ]; then
          echo "kadmin.local -q \"xst -k $tmpKeytabFile $principal\"" >> commands.xst;          
        fi
        echo "cp $tmpKeytabFile $newKeytabFile" >> commands.xst.cp
        
        if [ "$service" == "SPNEGO User" -o "$service" == "Ambari HDFS Test User" -o "$service" == "Ambari Smoke Test User" -o "$service" == "Ambari HBase Test User" ]; then
          echo "chmod 440 $newKeytabFile" >> commands.chmod.2
        else
          echo "chmod 400 $newKeytabFile" >> commands.chmod.2
        fi
        
        if [ "$service" == "NameNode" -o "$service" == "SNameNode" -o "$service" == "Ambari HDFS Test User" -o "$service" == "DataNode" ]; then
          echo "chown $USER_HDFS:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "TaskTracker" -o "$service" == "JobTracker" ]; then
          echo "chown $USER_MAPRED:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "Ambari Smoke Test User" ]; then
          echo "chown $USER_SMOKE:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "ZooKeeper Server" ]; then
          echo "chown $USER_ZK:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "HiveServer2" ]; then
          echo "chown $USER_HIVE:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "Oozie Server" ]; then
          echo "chown $USER_OOZIE:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "Nagios Server" ]; then
          echo "chown $USER_NAGIOS:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
        
        if [ "$service" == "Ambari HBase Test User" -o "$service" == "HBase RegionServer" -o "$service" == "HBase Master" ]; then
          echo "chown $USER_HBASE:$GROUP_HADOOP $newKeytabFile" >> commands.chown.1
        fi
    done;
    
    echo ""
    echo ""
    echo "###########################################################################"
    echo "# Making host specific keytab folders"
    echo "###########################################################################"
    cat commands.mkdir;
    echo ""
    echo "###########################################################################"
    echo "# Changing permissions for host specific keytab folders"
    echo "###########################################################################"
    cat commands.chmod;
    echo ""
    echo "###########################################################################"
    echo "# Creating Kerberos Principals"
    echo "###########################################################################"
    cat commands.addprinc;
    echo ""
    echo "###########################################################################"
    echo "# Creating Kerberos Principal keytabs in host specific keytab folders"
    echo "###########################################################################"
    cat commands.xst;
    cat commands.xst.cp;
    echo ""
    echo "###########################################################################"
    echo "# Changing ownerships of host specific keytab files"
    echo "###########################################################################"
    cat commands.chown.1
    echo ""
    echo "###########################################################################"
    echo "# Changing access permissions of host specific keytab files"
    echo "###########################################################################"
    #cat commands.chmod.1
    cat commands.chmod.2
    echo ""
    echo "###########################################################################"
    echo "# Packaging keytab folders"
    echo "###########################################################################"
    cat commands.tar
    echo ""
    echo "###########################################################################"
    echo "# Cleanup"
    echo "###########################################################################"
    echo "#rm -rf ./tmp_keytabs"
    
    rm -f commands.mkdir;
    rm -f commands.chmod;
    rm -f commands.addprinc;
    rm -f commands.xst
    rm -f commands.xst.cp
    rm -f commands.chown.1
    rm -f commands.chmod.1
    rm -f commands.chmod.2
    rm -f commands.tar
}

if (($# != 1)); then
    usage
fi

processCSVFile $1