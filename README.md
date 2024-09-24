# pgbench Load Testing

## Overview

This project provides a setup to perform load testing on the PostgreSQL database of insights, using `pgbench`. It enables custom SQL scripts with weighted execution to simulate real-world scenarios.

## Project Structure

- **`run_pgbench_for_duration.sh`**: Main script to execute the load tests for input duration in seconds.
- **`run_pgbench_for_txns.sh`**: Script t to execute the load tests for input number of transactions.
- **`run_pgbench.sh`**: Main script to execute the load tests.
- **`sql_weights.csv`**: Defines the SQL files and their respective weights for the test.
- **`sql_statements/`**: Directory containing SQL scripts categorized by table name.
- **`log/`**: Directory storing output logs from the `pgbench` runs.
- **`pgbench_env.conf`**: Environment configuration file to specify PostgreSQL connection details (host, port, user, and database).
## Usage

1. **Setup**: Ensure PostgreSQL is setup. `pgbench` comes with the package.
2. **Prepare SQL Files**: If you are adding new SQL statements, then place them in the corresponding directories under `sql_statements/`.
3. **Edit `sql_weights.csv`**: For a new SQL statement addition, define the table name, SQL file, and weight.

4. **Run the Test**:

   ```bash
   ./run_pgbench_for_duration.sh <number_of_connections> <duration_in_seconds>
   ./run_pgbench_for_txns.sh <number_of_connections> <total_transactions_per_connection>
   ```
   For e.g.
   ```bash
   ./run_pgbench_for_duration.sh 10 60
   ./run_pgbench_for_txns.sh 10 100
   ```
5. **Review Logs**: Check the log/ directory for detailed output.

