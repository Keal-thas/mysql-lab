package com.repro.druidoom;

import org.apache.catalina.connector.Connector;
import org.apache.coyote.http11.AbstractHttp11Protocol;
import org.springframework.boot.context.embedded.EmbeddedServletContainerInitializedEvent;
import org.springframework.boot.context.embedded.tomcat.TomcatEmbeddedServletContainer;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

/**
 * 只读出内嵌 Tomcat 实际生效的 maxThreads/acceptCount/connectionTimeout，
 * 用来验证 Spring Boot 1.5.9 到底有没有覆盖这几个默认值。
 */
@Component
public class TomcatConnectorLogger implements ApplicationListener<EmbeddedServletContainerInitializedEvent> {
    @Override
    public void onApplicationEvent(EmbeddedServletContainerInitializedEvent event) {
        if (event.getEmbeddedServletContainer() instanceof TomcatEmbeddedServletContainer) {
            TomcatEmbeddedServletContainer container = (TomcatEmbeddedServletContainer) event.getEmbeddedServletContainer();
            Connector connector = container.getTomcat().getConnector();
            AbstractHttp11Protocol<?> protocol = (AbstractHttp11Protocol<?>) connector.getProtocolHandler();
            System.out.println("### TOMCAT CONNECTOR DEFAULTS ### "
                    + "maxThreads=" + protocol.getMaxThreads()
                    + ", minSpareThreads=" + protocol.getMinSpareThreads()
                    + ", acceptCount=" + protocol.getAcceptCount()
                    + ", connectionTimeout=" + protocol.getConnectionTimeout()
                    + ", maxConnections=" + protocol.getMaxConnections());
        }
    }
}
