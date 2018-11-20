/**
 * Copyright © 2013 Antonin Stefanutti (antonin.stefanutti@gmail.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.astefanutti.metrics.aspectj.el;

import com.codahale.metrics.MetricRegistry;
import io.kgoldstein.metrics.annotation.ExceptionMetered;
import io.kgoldstein.metrics.annotation.Gauge;
import io.kgoldstein.metrics.annotation.Metered;
import io.kgoldstein.metrics.annotation.Timed;
import io.astefanutti.metrics.aspectj.Metrics;

@Metrics(registry = "${this.registry}")
public class MultipleMetricsMethodWithRegistryFromBeanProperty {

    private final MetricRegistry registry;

    public MultipleMetricsMethodWithRegistryFromBeanProperty(MetricRegistry registry) {
        this.registry = registry;
    }

    public MetricRegistry getRegistry() {
        return registry;
    }

    @ExceptionMetered(name = "exception")
    @Gauge(name = "gauge")
    @Metered(name = "meter")
    @Timed(name = "timer")
    public String metricsMethod() {
        return "value";
    }

    // Add a static method that does not declare any Metrics annotation to make sure the static aspect doesn't try to evaluate any expression
    public static void staticMethod() {
    }
}
