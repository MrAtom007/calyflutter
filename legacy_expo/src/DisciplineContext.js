import { createContext, useContext, useEffect, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = '@calistrack/discipline';
const DisciplineContext = createContext(null);

export const DISCIPLINES = {
  calisthenics: { id: 'calisthenics', label: 'Calisthenics', icon: '🤸' },
  gym: { id: 'gym', label: 'Palestra', icon: '🏋️' },
};

export function DisciplineProvider({ children }) {
  const [discipline, setDisciplineState] = useState('calisthenics');

  useEffect(() => {
    AsyncStorage.getItem(KEY).then((saved) => {
      if (saved === 'gym' || saved === 'calisthenics') setDisciplineState(saved);
    });
  }, []);

  const setDiscipline = (d) => {
    setDisciplineState(d);
    AsyncStorage.setItem(KEY, d);
  };

  return (
    <DisciplineContext.Provider value={{ discipline, setDiscipline }}>
      {children}
    </DisciplineContext.Provider>
  );
}

export function useDiscipline() {
  const ctx = useContext(DisciplineContext);
  if (!ctx) throw new Error('useDiscipline richiede DisciplineProvider');
  return ctx;
}
