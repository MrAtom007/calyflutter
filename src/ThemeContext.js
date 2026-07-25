import { createContext, useContext, useEffect, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { themes, defaultThemeId, freeThemeIds } from './theme';

const THEME_KEY = '@calistrack/themeId';
const GLOW_KEY = '@calistrack/glow';
const UNLOCKED_KEY = '@calistrack/unlocked';

const ThemeContext = createContext(null);

export function ThemeProvider({ children }) {
  const [themeId, setThemeId] = useState(defaultThemeId);
  const [glow, setGlow] = useState(true);
  const [unlocked, setUnlocked] = useState(freeThemeIds);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    (async () => {
      const [savedTheme, savedGlow, savedUnlocked] = await Promise.all([
        AsyncStorage.getItem(THEME_KEY),
        AsyncStorage.getItem(GLOW_KEY),
        AsyncStorage.getItem(UNLOCKED_KEY),
      ]);
      if (savedTheme && themes[savedTheme]) setThemeId(savedTheme);
      if (savedGlow !== null) setGlow(savedGlow === 'true');
      if (savedUnlocked) {
        const arr = JSON.parse(savedUnlocked);
        setUnlocked(Array.from(new Set([...freeThemeIds, ...arr])));
      }
      setReady(true);
    })();
  }, []);

  const changeTheme = (id) => {
    if (!themes[id]) return;
    setThemeId(id);
    AsyncStorage.setItem(THEME_KEY, id);
  };

  const toggleGlow = (value) => {
    setGlow(value);
    AsyncStorage.setItem(GLOW_KEY, value ? 'true' : 'false');
  };

  const unlock = (id) => {
    setUnlocked((prev) => {
      if (prev.includes(id)) return prev;
      const next = [...prev, id];
      AsyncStorage.setItem(UNLOCKED_KEY, JSON.stringify(next));
      return next;
    });
  };

  const isUnlocked = (id) => unlocked.includes(id);

  const theme = themes[themeId] || themes[defaultThemeId];
  // Glow attivo solo per i temi neon e se l'utente non l'ha disattivato.
  const glowActive = !!theme.neon && glow;

  return (
    <ThemeContext.Provider
      value={{ theme, themeId, changeTheme, glow, glowActive, toggleGlow, unlock, isUnlocked, unlocked, ready }}
    >
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme deve essere usato dentro ThemeProvider');
  return ctx;
}
