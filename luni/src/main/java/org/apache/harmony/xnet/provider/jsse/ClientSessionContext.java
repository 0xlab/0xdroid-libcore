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

package org.apache.harmony.xnet.provider.jsse;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.net.ssl.SSLSession;

/**
 * Caches client sessions. Indexes by host and port. Users are typically
 * looking to reuse any session for a given host and port. Users of the
 * standard API are forced to iterate over the sessions semi-linearly as
 * opposed to in constant time.
 */
public class ClientSessionContext extends AbstractSessionContext {

    /** Sessions indexed by host and port in access order. */
    final Map<HostAndPort, SSLSession> sessions
            = new LinkedHashMap<HostAndPort, SSLSession>() {
        @Override
        protected boolean removeEldestEntry(
                Map.Entry<HostAndPort, SSLSession> eldest) {
            // Called while lock is held on sessions.
            boolean remove = maximumSize > 0 && size() > maximumSize;
            if (remove) {
                // don't just update sessions, but also sessionsById
                removeById(eldest.getValue());
            }
            return remove;
        }
    };

    /**
     * Sessions indexed by ID. Initialized on demand. Protected from concurrent
     * access by holding a lock on sessions.
     */
    Map<ByteArray, SSLSession> sessionsById;

    private SSLClientSessionCache persistentCache;

    public ClientSessionContext() {
        super(10, 0);
    }

    public void setPersistentCache(SSLClientSessionCache persistentCache) {
        this.persistentCache = persistentCache;
    }

    public final void setSessionTimeout(int seconds)
            throws IllegalArgumentException {
        if (seconds < 0) {
            throw new IllegalArgumentException("seconds < 0");
        }
        timeout = seconds;

        synchronized (sessions) {
            Iterator<SSLSession> i = sessions.values().iterator();
            while (i.hasNext()) {
                SSLSession session = i.next();
                // SSLSession's know their context and consult the
                // timeout as part of their validity condition.
                if (!session.isValid()) {
                    i.remove();
                    // don't just update sessions, but also sessionsById
                    removeById(session);
                }
            }
        }
    }

    Iterator<SSLSession> sessionIterator() {
        synchronized (sessions) {
            SSLSession[] array = sessions.values().toArray(
                    new SSLSession[sessions.size()]);
            return Arrays.asList(array).iterator();
        }
    }

    void trimToSize() {
        synchronized (sessions) {
            int size = sessions.size();
            if (size > maximumSize) {
                int removals = size - maximumSize;
                Iterator<SSLSession> i = sessions.values().iterator();
                do {
                    removeById(i.next());
                    i.remove();
                } while (--removals > 0);
            }
        }
    }

    void removeById(SSLSession session) {
        if (sessionsById != null) {
            sessionsById.remove(new ByteArray(session.getId()));
        }
    }

    /**
     * {@inheritDoc}
     *
     * @see #getSession(String, int) for an implementation-specific but more
     *  efficient approach
     */
    public SSLSession getSession(byte[] sessionId) {
        if (sessionId == null) {
            throw new NullPointerException("sessionId == null");
        }
        /*
         * This method is typically used in conjunction with getIds() to
         * iterate over the sessions linearly, so it doesn't make sense for
         * it to impact access order.
         *
         * It also doesn't load sessions from the persistent cache as doing
         * so would likely force every session to load.
         */

        ByteArray id = new ByteArray(sessionId);
        SSLSession session;
        synchronized (sessions) {
            indexById();
            session = sessionsById.get(id);
        }
        if (session != null && session.isValid()) {
            return session;
        }
        return null;
    }

    /**
     * Ensures that the ID-based index is initialized.
     */
    private void indexById() {
        if (sessionsById == null) {
            sessionsById = new HashMap<ByteArray, SSLSession>();
            for (SSLSession session : sessions.values()) {
                sessionsById.put(new ByteArray(session.getId()), session);
            }
        }
    }

    /**
     * Adds the given session to the ID-based index if the index has already
     * been initialized.
     */
    private void indexById(byte[] id, SSLSession session) {
        if (sessionsById != null) {
            sessionsById.put(new ByteArray(id), session);
        }
    }

    /**
     * Finds a cached session for the given host name and port.
     *
     * @param host of server
     * @param port of server
     * @return cached session or null if none found
     */
    public SSLSession getSession(String host, int port) {
        SSLSession session;
        synchronized (sessions) {
            session = sessions.get(new HostAndPort(host, port));
        }
        if (session != null && session.isValid()) {
            return session;
        }

        // Look in persistent cache.
        if (persistentCache != null) {
            byte[] data = persistentCache.getSessionData(host, port);
            if (data != null) {
                session = toSession(data, host, port);
                if (session != null && session.isValid()) {
                    synchronized (sessions) {
                        sessions.put(new HostAndPort(host, port), session);
                        indexById(session.getId(), session);
                    }
                    return session;
                }
            }
        }

        return null;
    }

    @Override
    void putSession(SSLSession session) {
        byte[] id = session.getId();
        if (id.length == 0) {
            return;
        }
        HostAndPort key = new HostAndPort(session.getPeerHost(),
                session.getPeerPort());
        synchronized (sessions) {
            sessions.put(key, session);
            indexById(id, session);
        }

        // TODO: This in a background thread.
        if (persistentCache != null) {
            byte[] data = toBytes(session);
            if (data != null) {
                persistentCache.putSessionData(session, data);
            }
        }
    }

    static class HostAndPort {
        final String host;
        final int port;

        HostAndPort(String host, int port) {
            this.host = host;
            this.port = port;
        }

        @Override
        public int hashCode() {
            return host.hashCode() * 31 + port;
        }

        @Override
        @SuppressWarnings("EqualsWhichDoesntCheckParameterClass")
        public boolean equals(Object o) {
            HostAndPort other = (HostAndPort) o;
            return host.equals(other.host) && port == other.port;
        }
    }
}
