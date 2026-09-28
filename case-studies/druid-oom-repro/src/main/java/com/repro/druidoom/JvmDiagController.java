package com.repro.druidoom;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.management.BufferPoolMXBean;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.util.List;

@RestController
public class JvmDiagController {

    @GetMapping("/jvm")
    public String jvm() {
        ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
        List<BufferPoolMXBean> pools = ManagementFactory.getPlatformMXBeans(BufferPoolMXBean.class);

        StringBuilder sb = new StringBuilder();
        sb.append("threadCount=").append(threadMXBean.getThreadCount())
          .append(", peakThreadCount=").append(threadMXBean.getPeakThreadCount())
          .append('\n');
        for (BufferPoolMXBean pool : pools) {
            sb.append(pool.getName())
              .append(": count=").append(pool.getCount())
              .append(", memoryUsed=").append(pool.getMemoryUsed())
              .append(", totalCapacity=").append(pool.getTotalCapacity())
              .append('\n');
        }
        return sb.toString();
    }
}
