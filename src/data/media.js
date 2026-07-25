// Media dimostrativi per gli esercizi.
//
// Per ogni esercizio è possibile fornire immagine e video specifici tramite la
// mappa `curated` (chiave = id esercizio). Dove non presenti, si usano
// fallback affidabili validi per tutti gli esercizi:
//   - immagine: banner tematico con icona della categoria (renderizzato dalla UI)
//   - video: ricerca dimostrativa su YouTube caricata nel player in-app
//
// Ogni voce può contenere:
//   image   -> URL immagine specifica
//   videoId -> id YouTube per embed diretto
//   tags    -> tag immagine mirati (fallback LoremFlickr)
//   query   -> query YouTube mirata (dimostrazione più pertinente)
export const curated = {
  // ---- Push ----
  pushup: { tags: 'pushup,fitness', query: 'push up corretta esecuzione tutorial' },
  'diamond-pushup': { tags: 'pushup,triceps', query: 'diamond push up tutorial come si fa' },
  'archer-pushup': { tags: 'pushup,calisthenics', query: 'archer push up tutorial progressione' },
  'pike-pushup': { tags: 'pushup,shoulders', query: 'pike push up tutorial spalle' },
  hspu: { tags: 'handstand,calisthenics', query: 'handstand push up tutorial progressione' },
  dips: { tags: 'dips,calisthenics', query: 'dips parallele tutorial esecuzione' },
  'bench-dips': { tags: 'dips,triceps', query: 'bench dips tutorial tricipiti' },

  // ---- Pull ----
  pullup: { tags: 'pullup,calisthenics', query: 'pull up trazioni tutorial esecuzione corretta' },
  chinup: { tags: 'pullup,biceps', query: 'chin up tutorial presa supina' },
  'aussie-pullup': { tags: 'row,calisthenics', query: 'australian pull up tutorial' },
  muscleup: { tags: 'muscleup,calisthenics', query: 'muscle up tutorial progressione' },
  'inverted-row': { tags: 'row,bodyweight', query: 'inverted row tutorial rematore corpo libero' },
  'dead-hang': { tags: 'hang,calisthenics', query: 'dead hang tutorial presa sbarra' },

  // ---- Legs ----
  squat: { tags: 'squat,fitness', query: 'squat corpo libero tutorial esecuzione corretta' },
  lunge: { tags: 'lunge,legs', query: 'affondi tutorial esecuzione corretta' },
  'bulgarian-split': { tags: 'lunge,legs', query: 'bulgarian split squat tutorial' },
  'pistol-squat': { tags: 'squat,calisthenics', query: 'pistol squat tutorial progressione' },
  'glute-bridge': { tags: 'glute,fitness', query: 'glute bridge ponte glutei tutorial' },
  'wall-sit': { tags: 'squat,legs', query: 'wall sit tutorial isometria gambe' },
  'calf-raise': { tags: 'calf,legs', query: 'calf raise polpacci tutorial' },

  // ---- Core ----
  plank: { tags: 'plank,core', query: 'plank tutorial esecuzione corretta core' },
  'side-plank': { tags: 'plank,core', query: 'side plank plank laterale tutorial' },
  'hollow-hold': { tags: 'core,calisthenics', query: 'hollow hold tutorial core' },
  lsit: { tags: 'lsit,calisthenics', query: 'l sit tutorial progressione' },
  'leg-raise': { tags: 'abs,core', query: 'leg raise alzate gambe tutorial addominali' },
  'hanging-leg-raise': { tags: 'abs,calisthenics', query: 'hanging leg raise tutorial addominali sbarra' },
  crunch: { tags: 'abs,core', query: 'crunch addominali tutorial esecuzione' },
  'mountain-climber': { tags: 'core,cardio', query: 'mountain climber tutorial esecuzione' },
  'dragon-flag': { tags: 'abs,calisthenics', query: 'dragon flag tutorial progressione' },

  // ---- Skills ----
  handstand: { tags: 'handstand,calisthenics', query: 'handstand verticale tutorial equilibrio' },
  'front-lever': { tags: 'calisthenics,gymnastics', query: 'front lever tutorial progressione' },
  planche: { tags: 'planche,calisthenics', query: 'planche tutorial progressione' },
  'human-flag': { tags: 'calisthenics,gymnastics', query: 'human flag bandiera tutorial progressione' },
};

// Tag per immagine in base alla categoria (calisthenics + palestra).
const categoryTags = {
  Push: 'pushup,calisthenics',
  Pull: 'pullup,calisthenics',
  Legs: 'squat,workout',
  Core: 'abs,workout',
  Skills: 'calisthenics,gymnastics',
  Petto: 'benchpress,gym',
  Schiena: 'back,gym',
  Gambe: 'squat,gym',
  Spalle: 'shoulder,gym',
  Braccia: 'biceps,gym',
};

// Hash stabile dall'id per bloccare sempre la stessa immagine.
function lockFromId(id = '') {
  let h = 0;
  for (let i = 0; i < id.length; i++) h = (h * 31 + id.charCodeAt(i)) % 100000;
  return h;
}

// Immagine deterministica per un esercizio (fonte: LoremFlickr).
// Usa i tag curati quando disponibili, altrimenti quelli di categoria.
export function imageFor(exercise) {
  const c = curated[exercise?.id];
  const tags = c?.tags || categoryTags[exercise?.category] || 'fitness,workout';
  const lock = lockFromId(exercise?.id);
  return `https://loremflickr.com/640/360/${tags}?lock=${lock}`;
}

// Query dimostrativa (in italiano) per un esercizio.
export function demoQuery(exercise) {
  const c = curated[exercise?.id];
  if (c?.query) return c.query;
  return `${exercise?.name || ''} esercizio tutorial come si esegue`;
}

// URL mobile di YouTube con i risultati: l'utente riproduce il video in-app.
export function demoSearchUrl(exercise) {
  const q = encodeURIComponent(demoQuery(exercise));
  return `https://m.youtube.com/results?search_query=${q}`;
}

// URL di embed diretto quando è disponibile un video curato.
export function embedUrl(videoId) {
  return `https://www.youtube.com/embed/${videoId}?playsinline=1&rel=0`;
}

export function getMedia(exercise) {
  const c = curated[exercise?.id];
  return {
    image: c?.image || imageFor(exercise),
    videoId: c?.videoId || null,
    playUrl: c?.videoId ? embedUrl(c.videoId) : demoSearchUrl(exercise),
    direct: !!c?.videoId,
  };
}
