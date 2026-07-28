/// Frasi motivazionali mostrate nella Home Hero, ruotano ogni giorno.
const Map<String, List<String>> _motivation = {
  'it': [
    'La disciplina è il ponte tra obiettivi e risultati.',
    'Non conta quanto sei forte oggi, ma quanto vuoi esserlo domani.',
    'Ogni ripetizione ti avvicina alla tua versione migliore.',
    'Il dolore è temporaneo, la gloria è per sempre.',
    'Nessuno è mai annegato nel proprio sudore.',
    'Costruisci il corpo, forgia la mente.',
    'Le scuse non fanno crescere i muscoli.',
    'Un solo allenamento non cambia tutto, ma saltarlo sì.',
    'La forza non viene dal vincere: viene dalle difficoltà.',
    'Diventa così forte che nulla possa turbare la tua pace.',
    'Il ferro non mente mai.',
    'Alzati, allenati, ripeti. La leggenda si costruisce ogni giorno.',
    'Il tuo unico avversario è chi eri ieri.',
    'La costanza batte l\u2019intensità.',
    'Fatti trovare pronto: allena oggi ciò che vuoi essere domani.',
  ],
  'en': [
    'Discipline is the bridge between goals and results.',
    'It\u2019s not how strong you are today, but how strong you want to be.',
    'Every rep brings you closer to your best self.',
    'Pain is temporary, glory is forever.',
    'No one ever drowned in their own sweat.',
    'Build the body, forge the mind.',
    'Excuses don\u2019t build muscle.',
    'One workout won\u2019t change everything, but skipping it will.',
    'Strength doesn\u2019t come from winning, it comes from struggle.',
    'Become so strong nothing can disturb your peace.',
    'The iron never lies.',
    'Rise, train, repeat. Legends are built daily.',
    'Your only opponent is who you were yesterday.',
    'Consistency beats intensity.',
    'Train today what you want to be tomorrow.',
  ],
  'es': [
    'La disciplina es el puente entre metas y resultados.',
    'No importa cuán fuerte eres hoy, sino cuánto quieres serlo.',
    'Cada repetición te acerca a tu mejor versión.',
    'El dolor es temporal, la gloria es para siempre.',
    'Nadie se ahogó jamás en su propio sudor.',
    'Construye el cuerpo, forja la mente.',
    'Las excusas no crean músculo.',
    'Un entrenamiento no lo cambia todo, pero saltárselo sí.',
    'La fuerza no viene de ganar, viene de la lucha.',
    'Vuélvete tan fuerte que nada perturbe tu paz.',
    'El hierro nunca miente.',
    'Levántate, entrena, repite. Las leyendas se construyen a diario.',
    'Tu único rival es quien eras ayer.',
    'La constancia vence a la intensidad.',
    'Entrena hoy lo que quieres ser mañana.',
  ],
};

/// Ritorna la frase del giorno per la lingua indicata.
String motivationalQuote(String localeCode) {
  final list = _motivation[localeCode] ?? _motivation['en']!;
  final now = DateTime.now();
  final day = now.difference(DateTime(now.year)).inDays;
  return list[day % list.length];
}
