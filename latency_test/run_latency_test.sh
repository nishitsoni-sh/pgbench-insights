#!/bin/bash

# Variables
APP_NAME="title-chaining-demo"
DYNO="web.1"
SCRIPT_NAME="latency_test.sh"
REMOTE_DIR="/app/tmp"
OUTPUT_DIR="/var/log/my_crons/latency_test"
CRUNCHY_FILE="crunchy_latencies_$(date +%s).csv"
HEROKU_FILE="heroku_latencies_$(date +%s).csv"

# Hosts to ping (using environment variables)
CRUNCHY_HOST="p.3b77nodwrvgqfo5vlihh3qibne.db.postgresbridge.com:5432"
HEROKU_HOST="ec2-18-232-40-202.compute-1.amazonaws.com:5432"

cd $OUTPUT_DIR

# Step 1: Run the script on the dyno in the /app/tmp directory
echo "Running latency test on Heroku dyno..."
`which heroku` ps:exec --dyno $DYNO --app $APP_NAME << EOF
  cd $REMOTE_DIR

  # Function to log latency to file
  log_latency() {
    local host=\$1
    local file=\$2
    local timestamp=\$(date +"%Y-%m-%d %H:%M:%S")
    local latency=\$(curl -o /dev/null -s -w %{time_connect} \$host)

    echo "\$host,\$timestamp,\$latency" >> \$file
  }

  # Run the test 100 times for Crunchy host
  for i in {1..10}; do
    log_latency $CRUNCHY_HOST $CRUNCHY_FILE
    sleep 0.5
  done

  # Run the test 100 times for Heroku host
  for i in {1..10}; do
    log_latency $HEROKU_HOST $HEROKU_FILE
    sleep 0.5
  done

  echo "Latency tests completed. Results saved in $CRUNCHY_FILE and $HEROKU_FILE."
  exit
EOF

# Step 2: Download the resulting CSV files from the dyno back to local machine
echo "Downloading results to local machine..."
echo "Saving results to folder : `pwd`"
`which heroku` ps:copy "$REMOTE_DIR/$HEROKU_FILE" -a $APP_NAME -d $DYNO
`which heroku` ps:copy "$REMOTE_DIR/$CRUNCHY_FILE" -a $APP_NAME -d $DYNO

echo "Latency test completed. Results saved locally."
