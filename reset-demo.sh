echo "Stopping Storm topology"
storm kill Twittertopology

echo "Cleaning Tweets.xls"
rm -f /tmp/Tweets.xls

echo "Re-creating tweets hive tables"
hive -f /root/hdp_nifi_twitter_demo/twittertopology/twitter.sql
hive -e 'drop table tweets_orc_partition_single;'

echo "Resetting Solr/Banana"
/root/hdp_nifi_twitter_demo/setup-scripts/restart_solr_banana.sh

echo "Re-creating /tweets/staging HDFS dir"
sudo -u hdfs hadoop fs -rm -R /tweets
sudo -u hdfs hadoop fs -mkdir /tweets
sudo -u hdfs hadoop fs -chmod 777 /tweets
sudo -u hdfs hadoop fs -mkdir /tweets/staging
sudo -u hdfs hadoop fs -chmod 777 /tweets/staging

echo "Re-creating alerts table in HBase"
/root/hdp_nifi_twitter_demo/fetchSecuritiesList/runcreatehbasetables.sh

