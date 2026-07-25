# CaliStrack

App mobile per il tracking degli allenamenti di **calisthenics**, costruita con [Expo](https://expo.dev) e React Native.

## Funzionalità

- 📓 **Diario allenamenti** – registra e rivedi le tue sessioni
- ➕ **Nuovo allenamento** – aggiungi set per esercizio con reps o secondi
- 📋 **Libreria esercizi** – Push, Pull, Legs e Core con livello di difficoltà
- 💾 **Salvataggio locale** – dati persistiti con AsyncStorage
- 📊 **Statistiche rapide** – totale allenamenti e set

## Stack

- Expo ~57
- React Native 0.86
- React Navigation (stack + bottom tabs)
- AsyncStorage

## Avvio

```bash
npm install
npm start        # avvia il dev server Expo
npm run android  # Android
npm run ios      # iOS (richiede macOS)
npm run web      # browser
```

Scansiona il QR code con l'app **Expo Go** per provarla sul telefono.

## Struttura

```
src/
  data/exercises.js     libreria esercizi
  screens/              schermate (Home, NewWorkout, Detail, Exercises)
  navigation.js         tab + stack navigator
  storage.js            persistenza AsyncStorage
  theme.js              colori e spacing
App.js                  entry point
```
