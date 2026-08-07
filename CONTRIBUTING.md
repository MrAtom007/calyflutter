# Contribuire a CaliStrack

Grazie per l'interesse! Questa guida spiega come proporre modifiche in modo che
vengano revisionate e integrate rapidamente.

## Flusso di lavoro

1. **Forka** il repository e crea un branch descrittivo
   (`feature/...`, `fix/...`, `chore/...`).
2. Sviluppa la modifica **mirata** (una sola finalità per PR).
3. Assicurati che passino i controlli locali (vedi sotto).
4. Apri una **Pull Request** verso `main`: parte già dal template.
5. Il proprietario (@MrAtom007) è richiesto automaticamente come revisore.
   Nessuna modifica entra in `main` senza approvazione **e** CI verde.

> `main` è protetto: non sono possibili push diretti né force-push.

## Requisiti locali

Prima di aprire la PR esegui:

```bash
flutter pub get
dart format lib test          # formattazione (obbligatoria, la CI la verifica)
flutter analyze               # nessun issue
flutter test                  # tutti i test verdi
```

La CI (`.github/workflows/flutter-ci.yml`) ripete gli stessi passi ed è
**bloccante**: se falliscono, la PR non è mergiabile.

## Stile del codice

- **Dart/Flutter** con `flutter_lints`.
- Servizi come classi **statiche** con **degradazione graceful**
  (se un backend non è configurato, il metodo è un no-op sicuro).
- State management con **provider** (`ChangeNotifier`).
- Niente stringhe/segreti in chiaro: le API key si passano con
  `--dart-define` (es. RevenueCat), **mai** committate.

## Test

- Preferisci **unit test** per la logica pura (`test/`).
- Aggiungi test per i bug che correggi (regressione).

## Commit e PR

- Messaggi di commit brevi e in stile del repo
  (`feat:`, `fix:`, `chore:`, `docs:`...).
- Collega le issue con `Closes #NUMERO` nella descrizione della PR.
- Mantieni il diff contenuto e coerente.

## Segnalazioni

- Bug e proposte tramite gli appositi **template di issue**.
- Per domande generali usa le **Discussions**.

Grazie per contribuire a rendere CaliStrack migliore! 💪
