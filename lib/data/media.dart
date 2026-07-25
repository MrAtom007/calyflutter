import '../models/exercise.dart';

const Map<String, String> _curatedTags = {
  'pushup': 'pushup,fitness',
  'diamond-pushup': 'pushup,triceps',
  'archer-pushup': 'pushup,calisthenics',
  'pike-pushup': 'pushup,shoulders',
  'hspu': 'handstand,calisthenics',
  'dips': 'dips,calisthenics',
  'pullup': 'pullup,calisthenics',
  'muscleup': 'muscleup,calisthenics',
  'squat': 'squat,fitness',
  'plank': 'plank,core',
  'lsit': 'lsit,calisthenics',
  'handstand': 'handstand,calisthenics',
  'front-lever': 'calisthenics,gymnastics',
  'planche': 'planche,calisthenics',
  'human-flag': 'calisthenics,gymnastics',
};

const Map<String, String> _categoryTags = {
  'Push': 'pushup,calisthenics',
  'Pull': 'pullup,calisthenics',
  'Legs': 'squat,workout',
  'Core': 'abs,workout',
  'Skills': 'calisthenics,gymnastics',
  'Petto': 'benchpress,gym',
  'Schiena': 'back,gym',
  'Gambe': 'squat,gym',
  'Spalle': 'shoulder,gym',
  'Braccia': 'biceps,gym',
};

int _lockFromId(String id) {
  int h = 0;
  for (int i = 0; i < id.length; i++) {
    h = (h * 31 + id.codeUnitAt(i)) % 100000;
  }
  return h;
}

/// Immagine deterministica per un esercizio (LoremFlickr).
String imageFor(Exercise ex) {
  final tags =
      _curatedTags[ex.id] ?? _categoryTags[ex.category] ?? 'fitness,workout';
  final lock = _lockFromId(ex.id);
  return 'https://loremflickr.com/640/360/$tags?lock=$lock';
}

String demoQuery(Exercise ex) => '${ex.name} esercizio tutorial come si esegue';

/// URL di ricerca YouTube (aperto in WebView per il tutorial).
String demoSearchUrl(Exercise ex) {
  final q = Uri.encodeComponent(demoQuery(ex));
  return 'https://m.youtube.com/results?search_query=$q';
}
