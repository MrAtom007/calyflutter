import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  isEncryptionEnabled,
  setEncryptionFlag,
  encryptString,
  decryptString,
  ensureKey,
} from './crypto';

const WORKOUTS_KEY = '@calistrack/workouts';

// Un workout: { id, date (ISO), discipline, sets: [{ exerciseId, reps, sec, weight }] }

// Formato su disco:
//  - in chiaro:  '[ ... ]'  (array JSON)
//  - cifrato:    '{"__enc":1,"data":"<AES>"}'
// La lettura riconosce automaticamente entrambi i formati.
async function readAll() {
  try {
    const raw = await AsyncStorage.getItem(WORKOUTS_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (parsed && parsed.__enc) {
      const plain = await decryptString(parsed.data);
      return JSON.parse(plain);
    }
    return parsed;
  } catch (e) {
    console.warn('Errore lettura workouts', e);
    return [];
  }
}

// Scrive rispettando lo stato corrente della cifratura.
async function writeAll(list) {
  const json = JSON.stringify(list);
  if (await isEncryptionEnabled()) {
    const data = await encryptString(json);
    await AsyncStorage.setItem(WORKOUTS_KEY, JSON.stringify({ __enc: 1, data }));
  } else {
    await AsyncStorage.setItem(WORKOUTS_KEY, json);
  }
}

// Attiva la cifratura: genera la chiave e ricifra i dati esistenti.
export async function enableEncryption() {
  const all = await readAll();
  await ensureKey();
  await setEncryptionFlag(true);
  await writeAll(all);
}

// Disattiva la cifratura: riscrive i dati in chiaro.
export async function disableEncryption() {
  const all = await readAll();
  await setEncryptionFlag(false);
  await writeAll(all);
}

export { isEncryptionEnabled };

// getWorkouts() -> tutti; getWorkouts('gym') -> solo quelli della disciplina.
export async function getWorkouts(discipline) {
  const all = await readAll();
  const normalized = all.map((w) => ({
    ...w,
    discipline: w.discipline || 'calisthenics',
  }));
  if (!discipline) return normalized;
  return normalized.filter((w) => w.discipline === discipline);
}

export async function saveWorkout(workout) {
  const all = await readAll();
  const updated = [workout, ...all];
  await writeAll(updated);
  return updated;
}

// Importa un elenco di allenamenti (usato dal ripristino da backup JSON).
export async function importWorkouts(list, { merge = true } = {}) {
  const incoming = Array.isArray(list) ? list : [];
  const base = merge ? await readAll() : [];
  const byId = new Map();
  [...incoming, ...base].forEach((w) => {
    if (w && w.id) byId.set(String(w.id), w);
  });
  const merged = Array.from(byId.values()).sort(
    (a, b) => new Date(b.date) - new Date(a.date)
  );
  await writeAll(merged);
  return merged;
}

export async function deleteWorkout(id) {
  const all = await readAll();
  const updated = all.filter((w) => w.id !== id);
  await writeAll(updated);
  return updated;
}

export async function clearAll() {
  await AsyncStorage.removeItem(WORKOUTS_KEY);
}

const ONBOARDING_KEY = '@calistrack/onboarded';

export async function hasOnboarded() {
  return (await AsyncStorage.getItem(ONBOARDING_KEY)) === 'true';
}

export async function setOnboarded(value) {
  if (value) await AsyncStorage.setItem(ONBOARDING_KEY, 'true');
  else await AsyncStorage.removeItem(ONBOARDING_KEY);
}

// Ultimo livello "visto" per disciplina, per rilevare i level up.
const LAST_LEVEL_KEY = '@calistrack/lastLevel';

export async function getLastLevel(discipline) {
  const raw = await AsyncStorage.getItem(LAST_LEVEL_KEY);
  const map = raw ? JSON.parse(raw) : {};
  return map[discipline] ?? null;
}

export async function setLastLevel(discipline, level) {
  const raw = await AsyncStorage.getItem(LAST_LEVEL_KEY);
  const map = raw ? JSON.parse(raw) : {};
  map[discipline] = level;
  await AsyncStorage.setItem(LAST_LEVEL_KEY, JSON.stringify(map));
}

// Foto personalizzate per esercizio (URI locale scelto dall'utente).
const PHOTO_KEY = '@calistrack/exercisePhotos';

export async function getExercisePhoto(exerciseId) {
  const raw = await AsyncStorage.getItem(PHOTO_KEY);
  const map = raw ? JSON.parse(raw) : {};
  return map[exerciseId] || null;
}

export async function setExercisePhoto(exerciseId, uri) {
  const raw = await AsyncStorage.getItem(PHOTO_KEY);
  const map = raw ? JSON.parse(raw) : {};
  if (uri) map[exerciseId] = uri;
  else delete map[exerciseId];
  await AsyncStorage.setItem(PHOTO_KEY, JSON.stringify(map));
}

// Video personali per esercizio (URI locale scelto dalla galleria).
const VIDEO_KEY = '@calistrack/exerciseVideos';

export async function getExerciseVideo(exerciseId) {
  const raw = await AsyncStorage.getItem(VIDEO_KEY);
  const map = raw ? JSON.parse(raw) : {};
  return map[exerciseId] || null;
}

export async function setExerciseVideo(exerciseId, uri) {
  const raw = await AsyncStorage.getItem(VIDEO_KEY);
  const map = raw ? JSON.parse(raw) : {};
  if (uri) map[exerciseId] = uri;
  else delete map[exerciseId];
  await AsyncStorage.setItem(VIDEO_KEY, JSON.stringify(map));
}
