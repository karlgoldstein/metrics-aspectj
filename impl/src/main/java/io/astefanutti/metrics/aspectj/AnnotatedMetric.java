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

import io.micrometer.core.instrument.Meter;

import java.lang.annotation.Annotation;

public interface AnnotatedMetric<T extends Meter> {

    boolean isPresent();

    T getMetric();

    <A extends Annotation> A getAnnotation(Class<A> clazz);

    final class IsPresent<T extends Meter> implements AnnotatedMetric<T> {

        private final T metric;

        private final Annotation annotation;

        IsPresent(T metric, Annotation annotation) {
            this.metric = metric;
            this.annotation = annotation;
        }

        @Override
        public boolean isPresent() {
            return true;
        }

        @Override
        public T getMetric() {
            return metric;
        }

        @Override
        @SuppressWarnings("unchecked")
        public <A extends Annotation> A getAnnotation(Class<A> clazz) {
            return (A) annotation;
        }
    }

    final class IsNotPresent<T extends Meter> implements AnnotatedMetric<T> {

        @Override
        public boolean isPresent() {
            return false;
        }

        @Override
        public T getMetric() {
            throw new UnsupportedOperationException();
        }

        @Override
        @SuppressWarnings("unchecked")
        public <A extends Annotation> A getAnnotation(Class<A> clazz) {
            throw new UnsupportedOperationException();
        }
    }
}
