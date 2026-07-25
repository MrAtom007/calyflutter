import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';
import CryptoJS from 'crypto-js';

// Cifratura end-to-end (at-rest) della cronologia allenamenti.
// La chiave AES-256 è generata sul dispositivo e custodita nel Secure Store
// hardware del sistema: non lascia mai il telefono e non viene inviata online.

const ENC_KEY_NAME = 'calistrack_enc_key'; // chiave AES esadecimale
const ENC_FLAG_NAME = 'calistrack_enc_enabled'; // 'true' | assente

// Genera (una sola volta) e restituisce la chiave AES a 256 bit.
export async function ensureKey() {
  let key = await SecureStore.getItemAsync(ENC_KEY_NAME);
  if (!key) {
    const bytes = Crypto.getRandomBytes(32);
    key = Array.from(bytes)
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
    await SecureStore.setItemAsync(ENC_KEY_NAME, key);
  }
  return key;
}

export async function isEncryptionEnabled() {
  return (await SecureStore.getItemAsync(ENC_FLAG_NAME)) === 'true';
}

export async function setEncryptionFlag(value) {
  if (value) await SecureStore.setItemAsync(ENC_FLAG_NAME, 'true');
  else await SecureStore.deleteItemAsync(ENC_FLAG_NAME);
}

// Cifra una stringa con la chiave del dispositivo -> testo cifrato Base64.
export async function encryptString(plain) {
  const key = await ensureKey();
  return CryptoJS.AES.encrypt(plain, key).toString();
}

// Decifra un testo cifrato -> stringa in chiaro (throw se la chiave non combacia).
export async function decryptString(cipher) {
  const key = await ensureKey();
  const bytes = CryptoJS.AES.decrypt(cipher, key);
  const text = bytes.toString(CryptoJS.enc.Utf8);
  if (!text) throw new Error('Impossibile decifrare i dati');
  return text;
}
