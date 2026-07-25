import { createContext, useContext, useEffect, useState } from 'react';
import { hasOnboarded, setOnboarded } from './storage';

const OnboardingContext = createContext(null);

export function OnboardingProvider({ children }) {
  const [onboarded, setOnboardedState] = useState(null); // null = loading

  useEffect(() => {
    hasOnboarded().then(setOnboardedState);
  }, []);

  const finish = () => {
    setOnboarded(true);
    setOnboardedState(true);
  };

  const replay = () => {
    setOnboarded(false);
    setOnboardedState(false);
  };

  return (
    <OnboardingContext.Provider value={{ onboarded, finish, replay }}>
      {children}
    </OnboardingContext.Provider>
  );
}

export function useOnboarding() {
  const ctx = useContext(OnboardingContext);
  if (!ctx) throw new Error('useOnboarding richiede OnboardingProvider');
  return ctx;
}
