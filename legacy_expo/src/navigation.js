import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import HomeScreen from './screens/HomeScreen';
import NewWorkoutScreen from './screens/NewWorkoutScreen';
import WorkoutDetailScreen from './screens/WorkoutDetailScreen';
import ExercisesScreen from './screens/ExercisesScreen';
import ExerciseDetailScreen from './screens/ExerciseDetailScreen';
import RoutinesScreen from './screens/RoutinesScreen';
import ProgressScreen from './screens/ProgressScreen';
import RanksScreen from './screens/RanksScreen';
import SettingsScreen from './screens/SettingsScreen';
import TimerScreen from './screens/TimerScreen';
import StoreScreen from './screens/StoreScreen';
import HeaderMenu from './components/HeaderMenu';
import { useTheme } from './ThemeContext';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function useScreenOptions() {
  const { theme } = useTheme();
  return {
    headerStyle: { backgroundColor: theme.colors.card },
    headerTintColor: theme.colors.text,
    contentStyle: { backgroundColor: theme.colors.bg },
    animation: 'slide_from_right',
  };
}

function HomeStack() {
  const screenOptions = useScreenOptions();
  return (
    <Stack.Navigator screenOptions={screenOptions}>
      <Stack.Screen
        name="Diario"
        component={HomeScreen}
        options={({ navigation }) => ({
          title: 'CaliStrack',
          headerRight: () => <HeaderMenu navigation={navigation} />,
        })}
      />
      <Stack.Screen name="NewWorkout" component={NewWorkoutScreen} options={{ title: 'Nuovo allenamento' }} />
      <Stack.Screen name="WorkoutDetail" component={WorkoutDetailScreen} options={{ title: 'Dettaglio' }} />
      <Stack.Screen name="Timer" component={TimerScreen} options={{ title: 'Timer' }} />
      <Stack.Screen name="Store" component={StoreScreen} options={{ title: 'Neon Store' }} />
      <Stack.Screen name="EserciziStack" component={ExercisesScreen} options={{ title: 'Libreria esercizi' }} />
      <Stack.Screen name="ExerciseDetail" component={ExerciseDetailScreen} options={{ title: 'Esercizio' }} />
    </Stack.Navigator>
  );
}

function ExercisesStack() {
  const screenOptions = useScreenOptions();
  return (
    <Stack.Navigator screenOptions={screenOptions}>
      <Stack.Screen name="Libreria" component={ExercisesScreen} options={{ title: 'Esercizi' }} />
      <Stack.Screen name="ExerciseDetail" component={ExerciseDetailScreen} options={{ title: 'Esercizio' }} />
      <Stack.Screen name="Timer" component={TimerScreen} options={{ title: 'Timer' }} />
    </Stack.Navigator>
  );
}

const tabIcon = (name) => ({ color, size }) =>
  <MaterialCommunityIcons name={name} size={size ?? 22} color={color} />;

export default function RootNavigator() {
  const { theme } = useTheme();
  return (
    <Tab.Navigator
      screenOptions={{
        headerStyle: { backgroundColor: theme.colors.card },
        headerTintColor: theme.colors.text,
        animation: 'shift',
        tabBarStyle: {
          backgroundColor: theme.colors.card,
          borderTopColor: theme.colors.border,
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.textMuted,
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeStack}
        options={{ headerShown: false, tabBarIcon: tabIcon('home-variant') }}
      />
      <Tab.Screen name="Routine" component={RoutinesScreen} options={{ tabBarIcon: tabIcon('clipboard-list-outline') }} />
      <Tab.Screen name="Progressi" component={ProgressScreen} options={{ tabBarIcon: tabIcon('chart-line') }} />
      <Tab.Screen name="Medaglie" component={RanksScreen} options={{ tabBarIcon: tabIcon('medal-outline') }} />
      <Tab.Screen
        name="Esercizi"
        component={ExercisesStack}
        options={{ headerShown: false, tabBarIcon: tabIcon('dumbbell') }}
      />
      <Tab.Screen name="Impostazioni" component={SettingsScreen} options={{ tabBarIcon: tabIcon('cog-outline') }} />
    </Tab.Navigator>
  );
}
