package com.repro.druidoom;

import com.alibaba.druid.pool.DruidDataSource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@RestController
public class DbController {

    private final DataSource dataSource;

    public DbController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping("/query")
    public String query() {
        long start = System.currentTimeMillis();
        try (Connection conn = dataSource.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("select count(*) from employees")) {
            rs.next();
            long cost = System.currentTimeMillis() - start;
            return "ok, count=" + rs.getInt(1) + ", costMs=" + cost;
        } catch (Exception e) {
            long cost = System.currentTimeMillis() - start;
            return "ERROR after " + cost + "ms: " + e.getClass().getName() + ": " + e.getMessage();
        }
    }

    @GetMapping("/pool")
    public String pool() {
        if (dataSource instanceof DruidDataSource) {
            DruidDataSource d = (DruidDataSource) dataSource;
            return String.format(
                "maxActive=%d, minIdle=%d, initialSize=%d, maxWait=%d, activeCount=%d, poolingCount=%d, " +
                "waitThreadCount=%d, connectionErrorRetryAttempts=%d, timeBetweenConnectErrorMillis=%d, " +
                "createErrorCount=%d, notEmptyWaitCount=%d",
                d.getMaxActive(), d.getMinIdle(), d.getInitialSize(), d.getMaxWait(),
                d.getActiveCount(), d.getPoolingCount(), d.getWaitThreadCount(),
                d.getConnectionErrorRetryAttempts(), d.getTimeBetweenConnectErrorMillis(),
                d.getCreateErrorCount(), d.getNotEmptyWaitCount()
            );
        }
        return "not druid: " + dataSource.getClass();
    }
}
