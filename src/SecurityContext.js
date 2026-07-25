import { createContext, useContext, useEffect, useRef, useState } from 'react';
import { AppState } from 'react-native';
import { getLockMode, getLockPolicy, LOCK_MODES, LOCK_POLICIES, GRACE_MS } from './security';

const SecurityContext = createContext(null);

export function SecurityProvider({ children }) {
  const [mode, setMode] = useState(LOCK_MODES.NONE);
  const [policy, setPolicy] = useState(LOCK_POLICIES.LAUNCH);
  const [locked, setLocked] = useState(false);
  const [ready, setReady] = useState(false);
  const appState = useRef(AppState.currentState);
  const backgroundedAt = useRef(null);

  const refresh = async () => {
    const [m, p] = await Promise.all([getLockMode(), getLockPolicy()]);
    setMode(m);
    setPolicy(p);
    return { m, p };
  };

  useEffect(() => {
    (async () => {
      const { m } = await refresh();
      // Al primo avvio blocca sempre (cold start) se c'è un metodo attivo.
      if (m !== LOCK_MODES.NONE) setLocked(true);
      setReady(true);
    })();
  }, []);

  // Gestione transizioni di stato dell'app.
  useEffect(() => {
    const sub = AppState.addEventListener('change', (next) => {
      const prev = appState.current;
      appState.current = next;

      // Va in background: registra il momento.
      if (prev === 'active' && (next === 'background' || next === 'inactive')) {
        backgroundedAt.current = Date.now();
      }

      // Torna in primo piano: decide se bloccare in base alla policy.
      if ((prev === 'background' || prev === 'inactive') && next === 'active') {
        if (mode === LOCK_MODES.NONE) return;
        if (policy === LOCK_POLICIES.LAUNCH) return; // mai al resume
        if (policy === LOCK_POLICIES.IMMEDIATE) {
          setLocked(true);
          return;
        }
        // GRACE: blocca solo se rimasta in background a lungo.
        const elapsed = backgroundedAt.current ? Date.now() - backgroundedAt.current : 0;
        if (elapsed > GRACE_MS) setLocked(true);
      }
    });
    return () => sub.remove();
  }, [mode, policy]);

  const unlock = () => setLocked(false);

  const syncSettings = async () => {
    const { m } = await refresh();
    if (m === LOCK_MODES.NONE) setLocked(false);
  };

  return (
    <SecurityContext.Provider
      value={{ mode, policy, locked, ready, unlock, syncSettings, setLocked }}
    >
      {children}
    </SecurityContext.Provider>
  );
}

export function useSecurity() {
  const ctx = useContext(SecurityContext);
  if (!ctx) throw new Error('useSecurity richiede SecurityProvider');
  return ctx;
}
