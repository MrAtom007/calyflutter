# Privacy Policy di CaliStrack

_Ultimo aggiornamento: 6 agosto 2026_

Questa Privacy Policy descrive come l'applicazione **CaliStrack** (package `com.calistrack.calistrack`, di seguito "l'App") tratta i dati degli utenti. L'App è un tracker per allenamenti di calisthenics e palestra. Utilizzando l'App accetti le pratiche descritte in questo documento.

## 1. Titolare del trattamento
Titolare: **Tomas Racioppi** (sviluppatore di CaliStrack).
Contatto: **tomasracioppi003@gmail.com**

## 2. Principio generale: i dati restano sul tuo dispositivo
CaliStrack è progettata per funzionare in locale. Tutti i tuoi dati (allenamenti, impostazioni, obiettivi, dati di salute in cache) sono salvati **sul tuo dispositivo**. L'App funziona pienamente **senza alcun account** e senza connessione a servizi cloud.

Il salvataggio su cloud avviene **solo se scegli volontariamente di effettuare l'accesso con il tuo account Google** (vedi sezione 5).

## 3. Dati di salute e fitness
Se concedi il permesso, l'App legge (in **sola lettura**, non scrive mai) i seguenti dati da **Health Connect** (Android) o **Apple Health** (iOS), per mostrarti statistiche e progressi:

- Frequenza cardiaca e frequenza cardiaca a riposo
- Variabilità della frequenza cardiaca (HRV)
- Pressione sanguigna
- Ossigenazione del sangue (SpO2)
- Passi
- Calorie attive e totali bruciate
- Sonno
- Riconoscimento attività fisica

Questi dati vengono usati **esclusivamente all'interno dell'App** per mostrarti dashboard e andamenti. Sono salvati in cache sul dispositivo. Non vengono venduti né condivisi con terze parti per pubblicità. Se effettui l'accesso con Google, questi dati sono inclusi nel backup del tuo account (vedi sezione 5). Puoi revocare in qualsiasi momento i permessi salute dalle impostazioni di Health Connect / Apple Health.

## 4. Autenticazione con Google (facoltativa)
L'accesso è **opzionale**. Se scegli di accedere tramite **Google Sign-In**, l'App raccoglie:

- **Indirizzo email** del tuo account Google (salvato per associare il backup al tuo account);
- **Nome e foto profilo** (usati solo per la visualizzazione nell'interfaccia, non salvati sul cloud).

L'autenticazione è gestita tramite **Firebase Authentication** di Google.

## 5. Backup su cloud (Firestore) — solo con accesso effettuato
Se hai effettuato l'accesso con Google, l'App effettua un backup del tuo stato su **Google Cloud Firestore**, in un documento privato associato al tuo account. Il backup può includere:

- I tuoi allenamenti e progressi
- Obiettivi e impostazioni
- Dati di salute in cache (vedi sezione 3)
- Preferenze di aspetto (tema) e disciplina
- L'indirizzo email dell'account

Questi dati sono accessibili **solo a te** tramite il tuo account. Se non effettui l'accesso, **nessun dato lascia il dispositivo**.

## 6. Sicurezza dell'App
L'App offre funzioni di sicurezza locali:

- **Blocco con PIN o biometria** (impronta/volto). Il PIN è salvato solo come hash cifrato (SHA-256 con salt) in un archivio sicuro del dispositivo. I dati biometrici sono gestiti dal sistema operativo e non sono mai letti né memorizzati dall'App.
- **Cifratura opzionale AES-256** dei dati di allenamento sul dispositivo.
- **Firebase App Check** (Play Integrity) per proteggere le comunicazioni con i servizi cloud da abusi.

## 7. Notifiche
L'App usa **solo notifiche locali** per i promemoria di allenamento che imposti tu. **Non** vengono usate notifiche push né inviati dati a server per le notifiche.

## 8. Altri permessi
- **Notifiche / allarmi esatti**: per i promemoria programmati.
- **Biometria**: per lo sblocco dell'App.
- **Condivisione**: per esportare i tuoi dati (CSV/JSON) tramite il menu di condivisione del sistema, su tua richiesta.
- **Widget schermata home**: mostra dati (es. battito, passi, rango) che restano sul dispositivo.

## 9. Assenza di tracciamento e pubblicità
CaliStrack **non** contiene sistemi di analytics, **non** traccia gli utenti a fini pubblicitari, **non** mostra pubblicità e **non** vende i tuoi dati. Gli unici servizi esterni utilizzati sono Firebase (Authentication, Firestore, App Check), forniti da Google, e solo per le finalità di autenticazione e backup descritte sopra.

## 10. Servizi di terze parti
- **Google / Firebase** — autenticazione e backup cloud. Privacy: https://policies.google.com/privacy
- **Health Connect (Android) / Apple Health (iOS)** — origine dei dati di salute, previo tuo consenso.

## 11. Conservazione ed eliminazione dei dati
I dati locali restano finché non disinstalli l'App o cancelli i dati dalle sue impostazioni. Se hai usato il backup cloud, puoi richiedere l'eliminazione dei dati associati al tuo account scrivendo all'indirizzo di contatto indicato nella sezione 1. Revocando i permessi salute interrompi la lettura dei relativi dati.

## 12. Minori
L'App non è destinata a minori di 13 anni e non raccoglie consapevolmente i loro dati.

## 13. Modifiche a questa policy
Questa policy può essere aggiornata. La data in alto indica l'ultima revisione. Le modifiche rilevanti saranno comunicate tramite l'App o questa pagina.

## 14. Contatti
Per domande sulla privacy o richieste sui tuoi dati: **tomasracioppi003@gmail.com**
