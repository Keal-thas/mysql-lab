package com.repro.druidoom;

import com.alibaba.druid.pool.DruidDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class DruidConfig {

    @Bean
    @ConfigurationProperties(prefix = "druid")
    public DataSource dataSource() {
        return new DruidDataSource();
    }
}
