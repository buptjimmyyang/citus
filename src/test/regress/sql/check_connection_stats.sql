
-- disable 2pc recovery and deadlock detection to prevent
-- random failures in the tests (otherwise, we might see
-- connections established for this operations)
ALTER SYSTEM SET citus.distributed_deadlock_detection_factor TO -1;
ALTER SYSTEM SET citus.recover_2pc_interval TO '1h';

-- ensure that we only have at most citus.max_cached_conns_per_worker
-- connections per node
select
	hostname, port, database_name,
	connection_count_to_node <= (select setting::int from pg_settings WHERE name = 'citus.max_cached_conns_per_worker'),
FROM
	citus_remote_connection_stats()
WHERE
	port IN (:worker_1_port, :worker_2_port) AND
	database_name = 'regression'
ORDER BY 1,2,3,4;
