/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package dalvik.runner;

import java.lang.reflect.Method;

/**
 * Runs a jtreg test.
 */
public final class JtregRunner implements Runner {

    private Method main;

    public void prepareTest(Class<?> testClass) {
        try {
            main = testClass.getMethod("main", String[].class);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean test(Class<?> testClass) {
        try {
            main.invoke(null, new Object[] { new String[0] });
            return true;
        } catch (Throwable failure) {
            failure.printStackTrace();
            return false;
        }
    }
}
