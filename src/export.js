import { Share, Alert, Platform } from 'react-native';
import { File, Paths } from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import { getWorkouts } from './storage';
import { getExercise } from './data/exercises';

// Esporta la cronologia allenamenti in CSV o JSON e apre il foglio di
// condivisione del sistema (salva su file, invia via mail, ecc.).

function fmtDate(iso) {
  const d = new Date(iso);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(
    d.getHours()
  )}:${pad(d.getMinutes())}`;
}

function stamp() {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}-${pad(
    d.getHours()
  )}${pad(d.getMinutes())}`;
}

function csvEscape(value) {
  const s = value === null || value === undefined ? '' : String(value);
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

// Trasforma i workout in righe (una per set).
export function buildRows(workouts) {
  const rows = [];
  workouts.forEach((w) => {
    (w.sets || []).forEach((s) => {
      const ex = getExercise(s.exerciseId);
      rows.push({
        data: fmtDate(w.date),
        disciplina: w.discipline || 'calisthenics',
        esercizio: ex?.name || s.exerciseId,
        categoria: ex?.category || '',
        reps: s.reps ?? '',
        secondi: s.sec ?? '',
        peso_kg: s.weight ?? '',
      });
    });
  });
  return rows;
}

export function toCSV(workouts) {
  const rows = buildRows(workouts);
  const headers = ['data', 'disciplina', 'esercizio', 'categoria', 'reps', 'secondi', 'peso_kg'];
  const lines = [headers.join(',')];
  rows.forEach((r) => lines.push(headers.map((h) => csvEscape(r[h])).join(',')));
  return lines.join('\n');
}

export function toJSON(workouts) {
  return JSON.stringify(
    {
      app: 'CaliStrack',
      exportedAt: new Date().toISOString(),
      count: workouts.length,
      workouts,
    },
    null,
    2
  );
}

async function writeAndShare(filename, content, mimeType) {
  const file = new File(Paths.cache, filename);
  try {
    if (file.exists) file.delete();
  } catch (_) {}
  file.create();
  file.write(content);
  if (await Sharing.isAvailableAsync()) {
    await Sharing.shareAsync(file.uri, { mimeType, dialogTitle: 'Esporta allenamenti' });
    return true;
  }
  await Share.share({ message: content });
  return true;
}

// discipline: undefined = tutte; 'gym' | 'calisthenics' per filtrare.
export async function exportWorkouts(format = 'csv', discipline) {
  try {
    const workouts = await getWorkouts(discipline);
    if (workouts.length === 0) {
      Alert.alert('Nessun dato', 'Registra qualche allenamento prima di esportare.');
      return false;
    }
    if (format === 'json') {
      return await writeAndShare(
        `calistrack-${stamp()}.json`,
        toJSON(workouts),
        'application/json'
      );
    }
    return await writeAndShare(`calistrack-${stamp()}.csv`, toCSV(workouts), 'text/csv');
  } catch (e) {
    if (e?.message?.includes('cancel')) return false;
    Alert.alert('Esportazione non riuscita', e?.message || 'Riprova più tardi.');
    return false;
  }
}
