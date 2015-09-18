source ambari_util.sh

AMBARI_STARTED=`ps -ef | grep AmbariServe[r] | wc -l`
if [ ! $AMBARI_STARTED ]
then
	echo 'Starting Ambari'
	if [ -f /root/start_ambari.sh ]
	then
		/root/start_ambari.sh
	else
		ambari-server start
		ambari-agent start
	fi
	sleep 5
fi

service ranger-admin start

echo '*** Starting Storm....'
startWait STORM

echo '*** Starting HBase....'
startWait HBASE

echo '*** Starting kafka....'
startWait KAFKA

#/root/hdp_nifi_twitter_demo/setup-scripts/restart_solr_banana.sh
nohup java -jar /opt/solr/latest/hdp/start.jar -Djetty.home=/opt/solr/latest/hdp -Dsolr.solr.home=/opt/solr/latest/hdp/solr &> /root/hdp_nifi_twitter_demo/logs/solr.out &

if [ -f /opt/lucidworks-hdpsearch/solr/ranger_audit_server/scripts/start_solr.sh ]
then
        /opt/lucidworks-hdpsearch/solr/ranger_audit_server/scripts/start_solr.sh
fi

if [ -f /opt/solr/ranger_audit_server/scripts/start_solr.sh ]
then
        /opt/solr/ranger_audit_server/scripts/start_solr.sh
fi

cd ~/hdp_nifi_twitter_demo/twittertopology
if [ ! -f target/storm-streaming-1.0-SNAPSHOT.jar ]
then
	echo "First compile detected, running mvn purge local"
	mvn dependency:purge-local-repository
else
	echo "Uber jar found, running regular mvn compile"	
fi	
./runtopology.sh

