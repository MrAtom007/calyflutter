import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';
import * as LocalAuthentication from 'expo-local-authentication';

const MODE_KEY = 'calistrack_lock_mode'; // 'none' | 'pin' | 'device'
const PIN_HASH_KEY = 'calistrack_pin_hash';
const PIN_SALT_KEY = 'calistrack_pin_salt';
const BIO_QUICK_KEY = 'calistrack_bio_quick'; // sblocco rapido biometrico in modalità PIN
const POLICY_KEY = 'calistrack_lock_policy'; // quando richiedere lo sblocco

export const LOCK_MODES = { NONE: 'none', PIN: 'pin', DEVICE: 'device' };

// Politiche di sblocco:
// - LAUNCH: solo al primo avvio dell'app (default). Riaprendo dal background NON chiede nulla.
// - GRACE: chiede solo se l'app è rimasta in background oltre ~2 minuti.
// - IMMEDIATE: chiede ogni volta che si torna in primo piano.
export const LOCK_POLICIES = { LAUNCH: 'launch', GRACE: 'grace', IMMEDIATE: 'immediate' };
export const GRACE_MS = 2 * 60 * 1000;

export async function getLockPolicy() {
  return (await SecureStore.getItemAsync(POLICY_KEY)) || LOCK_POLICIES.LAUNCH;
}

export async function setLockPolicy(policy) {
  await SecureStore.setItemAsync(POLICY_KEY, policy);
}

async function sha256(value) {
  return Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, value);
}

function randomSalt() {
  const bytes = Crypto.getRandomBytes(32);
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

// ---- Modalità di blocco ----
export async function getLockMode() {
  return (await SecureStore.getItemAsync(MODE_KEY)) || LOCK_MODES.NONE;
}

export async function disableLock() {
  await SecureStore.deleteItemAsync(PIN_HASH_KEY);
  await SecureStore.deleteItemAsync(PIN_SALT_KEY);
  await SecureStore.deleteItemAsync(BIO_QUICK_KEY);
  await SecureStore.setItemAsync(MODE_KEY, LOCK_MODES.NONE);
}

// ---- PIN ----
export async function setPin(pin) {
  const salt = randomSalt();
  const hash = await sha256(salt + pin);
  await SecureStore.setItemAsync(PIN_SALT_KEY, salt);
  await SecureStore.setItemAsync(PIN_HASH_KEY, hash);
  await SecureStore.setItemAsync(MODE_KEY, LOCK_MODES.PIN);
}

export async function verifyPin(pin) {
  const salt = await SecureStore.getItemAsync(PIN_SALT_KEY);
  const stored = await SecureStore.getItemAsync(PIN_HASH_KEY);
  if (!salt || !stored) return false;
  const hash = await sha256(salt + pin);
  return hash === stored;
}

// ---- Blocco del dispositivo (biometria o codice schermo) ----
export async function setDeviceMode() {
  await SecureStore.setItemAsync(MODE_KEY, LOCK_MODES.DEVICE);
}

// ---- Sblocco rapido biometrico (in modalità PIN) ----
export async function isBioQuickEnabled() {
  return (await SecureStore.getItemAsync(BIO_QUICK_KEY)) === 'true';
}

export async function setBioQuickEnabled(value) {
  await SecureStore.setItemAsync(BIO_QUICK_KEY, value ? 'true' : 'false');
}

// ---- Capacità del dispositivo ----
export async function getSecuritySupport() {
  const hasHardware = await LocalAuthentication.hasHardwareAsync();
  const enrolledBiometric = await LocalAuthentication.isEnrolledAsync();
  const level = await LocalAuthentication.getEnrolledLevelAsync();
  const types = await LocalAuthentication.supportedAuthenticationTypesAsync();
  const isFace = types.includes(
    LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION
  );
  return {
    biometricAvailable: hasHardware && enrolledBiometric,
    biometricLabel: isFace ? 'Face ID' : 'Impronta digitale',
    // SECRET = codice/PIN/pattern del dispositivo o biometria impostati
    deviceLockAvailable: level !== LocalAuthentication.SecurityLevel.NONE,
  };
}

// Autenticazione biometrica pura (fallback: PIN dell'app gestito dalla UI).
export async function authenticateBiometric() {
  const res = await LocalAuthentication.authenticateAsync({
    promptMessage: 'Sblocca CaliStrack',
    cancelLabel: 'Usa PIN',
    disableDeviceFallback: true,
  });
  return res.success;
}

// Autenticazione con blocco del dispositivo: biometria + fallback al
// codice/impronta dello schermo del telefono.
export async function authenticateDevice() {
  const res = await LocalAuthentication.authenticateAsync({
    promptMessage: 'Sblocca CaliStrack',
    disableDeviceFallback: false,
  });
  return res.success;
}
