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
package io.astefanutti.metrics.aspectj;

import com.codahale.metrics.Metric;
import io.kgoldstein.metrics.annotation.ExceptionMetered;
import io.kgoldstein.metrics.annotation.Gauge;
import io.kgoldstein.metrics.annotation.Metered;
import io.kgoldstein.metrics.annotation.Timed;

import java.lang.annotation.Annotation;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

abstract aspect AbstractMetricAspect {

    protected interface MetricFactory<T extends Metric> {
        T metric(String name, boolean absolute);
    }

    protected <T extends Metric> AnnotatedMetric<T> metricAnnotation(Method method, Class<? extends Annotation> clazz, MetricFactory<T> factory) {
        if (method.isAnnotationPresent(clazz)) {
            Annotation annotation = method.getAnnotation(clazz);
            T metric = factory.metric(metricAnnotationName(annotation), metricAnnotationAbsolute(annotation));
            return new AnnotatedMetric.IsPresent<T>(metric, annotation);
        } else {
            return new AnnotatedMetric.IsNotPresent<T>();
        }
    }

    protected static String metricAnnotationName(Annotation annotation) {
        if (Gauge.class.isInstance(annotation))
            return ((Gauge) annotation).name();
        else if (ExceptionMetered.class.isInstance(annotation))
            return ((ExceptionMetered) annotation).name();
        else if (Metered.class.isInstance(annotation))
            return ((Metered) annotation).name();
        else if (Timed.class.isInstance(annotation))
            return ((Timed) annotation).name();
        else
            throw new IllegalArgumentException("Unsupported Metrics annotation [" + annotation.getClass().getName() + "]");
    }

    protected static boolean metricAnnotationAbsolute(Annotation annotation) {
        if (Gauge.class.isInstance(annotation))
            return ((Gauge) annotation).absolute();
        else if (ExceptionMetered.class.isInstance(annotation))
            return ((ExceptionMetered) annotation).absolute();
        else if (Metered.class.isInstance(annotation))
            return ((Metered) annotation).absolute();
        else if (Timed.class.isInstance(annotation))
            return ((Timed) annotation).absolute();
        else
            throw new IllegalArgumentException("Unsupported Metrics annotation [" + annotation.getClass().getName() + "]");
    }

    protected static class ForwardingGauge implements com.codahale.metrics.Gauge<Object> {

        final Method method;
        final Object object;

        protected ForwardingGauge(Method method, Object object) {
            this.method = method;
            this.object = object;
            method.setAccessible(true);
        }

        @Override
        public Object getValue() {
            // TODO: use more efficient technique than reflection
            return invokeMethod(method, object);
        }
    }

    private static Object invokeMethod(Method method, Object object) {
        try {
            return method.invoke(object);
        } catch (IllegalAccessException cause) {
            throw new IllegalStateException("Error while calling method [" + method + "]", cause);
        } catch (InvocationTargetException cause) {
            throw new IllegalStateException("Error while calling method [" + method + "]", cause);
        }
    }
}
