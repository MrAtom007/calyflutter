import { Share, Alert, Platform } from 'react-native';
import { captureRef } from 'react-native-view-shot';
import * as Sharing from 'expo-sharing';

// Condivide la card come immagine; fallback su testo se non disponibile.
export async function shareProgressImage(viewRef, textFallback) {
  try {
    const uri = await captureRef(viewRef, {
      format: 'png',
      quality: 1,
      result: 'tmpfile',
    });
    if (await Sharing.isAvailableAsync()) {
      await Sharing.shareAsync(uri, {
        mimeType: 'image/png',
        dialogTitle: 'Condividi i tuoi progressi',
      });
      return;
    }
    // Fallback testo
    await Share.share({ message: textFallback });
  } catch (e) {
    if (e?.message?.includes('cancel')) return;
    try {
      await Share.share({ message: textFallback });
    } catch (_) {
      Alert.alert('Condivisione non disponibile', 'Riprova piu\u2019 tardi.');
    }
  }
}
