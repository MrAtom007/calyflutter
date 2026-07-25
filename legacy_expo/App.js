import { View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer, DarkTheme, DefaultTheme } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import RootNavigator from './src/navigation';
import OnboardingScreen from './src/screens/OnboardingScreen';
import LockScreen from './src/screens/LockScreen';
import { ThemeProvider, useTheme } from './src/ThemeContext';
import { DisciplineProvider } from './src/DisciplineContext';
import { OnboardingProvider, useOnboarding } from './src/OnboardingContext';
import { SecurityProvider, useSecurity } from './src/SecurityContext';
import { LevelUpProvider } from './src/LevelUpContext';

function AppContent() {
  const { theme, ready: themeReady } = useTheme();
  const { onboarded, finish } = useOnboarding();
  const { locked, ready: secReady } = useSecurity();

  const base = theme.mode === 'light' ? DefaultTheme : DarkTheme;
  const navTheme = {
    ...base,
    colors: {
      ...base.colors,
      background: theme.colors.bg,
      card: theme.colors.card,
      text: theme.colors.text,
      primary: theme.colors.primary,
      border: theme.colors.border,
    },
  };

  if (!themeReady || !secReady || onboarded === null) {
    return <View style={{ flex: 1, backgroundColor: theme.colors.bg }} />;
  }

  const statusBar = <StatusBar style={theme.mode === 'light' ? 'dark' : 'light'} />;

  // Il blocco ha priorità: schermata di sblocco prima di tutto.
  if (locked) {
    return (
      <>
        {statusBar}
        <LockScreen />
      </>
    );
  }

  if (!onboarded) {
    return (
      <>
        {statusBar}
        <OnboardingScreen onDone={finish} />
      </>
    );
  }

  return (
    <>
      {statusBar}
      <NavigationContainer theme={navTheme}>
        <LevelUpProvider>
          <RootNavigator />
        </LevelUpProvider>
      </NavigationContainer>
    </>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <ThemeProvider>
        <SecurityProvider>
          <DisciplineProvider>
            <OnboardingProvider>
              <AppContent />
            </OnboardingProvider>
          </DisciplineProvider>
        </SecurityProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
