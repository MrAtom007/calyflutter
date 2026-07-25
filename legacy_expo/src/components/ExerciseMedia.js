import { useCallback, useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  Image,
  ActivityIndicator,
  Pressable,
} from 'react-native';
import { WebView } from 'react-native-webview';
import { useVideoPlayer, VideoView } from 'expo-video';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import * as Haptics from 'expo-haptics';
import { useFocusEffect } from '@react-navigation/native';
import { useTheme } from '../ThemeContext';
import { categoryIcon } from '../data/icons';
import { getMedia } from '../data/media';
import {
  getExercisePhoto,
  setExercisePhoto,
  getExerciseVideo,
  setExerciseVideo,
} from '../storage';
import { spacing, radius, glowShadow } from '../theme';

// Banner immagine (con foto personale opzionale) + Play video + visore fullscreen.
export default function ExerciseMedia({ exercise }) {
  const { theme, glowActive } = useTheme();
  const styles = useMemo(() => makeStyles(theme.colors), [theme]);
  const [playerOpen, setPlayerOpen] = useState(false);
  const [videoOpen, setVideoOpen] = useState(false);
  const [viewerOpen, setViewerOpen] = useState(false);
  const [imgError, setImgError] = useState(false);
  const [customPhoto, setCustomPhoto] = useState(null);
  const [customVideo, setCustomVideo] = useState(null);
  const media = useMemo(() => getMedia(exercise), [exercise]);

  // Player nativo (expo-video) per l'eventuale video personale.
  const player = useVideoPlayer(customVideo || null, (p) => {
    if (p) p.loop = true;
  });

  useFocusEffect(
    useCallback(() => {
      let active = true;
      setImgError(false);
      getExercisePhoto(exercise?.id).then((uri) => active && setCustomPhoto(uri));
      getExerciseVideo(exercise?.id).then((uri) => active && setCustomVideo(uri));
      return () => {
        active = false;
      };
    }, [exercise?.id])
  );

  const imageUri = customPhoto || media.image;
  const showImage = imageUri && !imgError;

  const pickPhoto = async () => {
    Haptics.selectionAsync();
    const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) return;
    const res = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [16, 9],
      quality: 0.8,
    });
    if (!res.canceled && res.assets?.[0]?.uri) {
      const uri = res.assets[0].uri;
      await setExercisePhoto(exercise.id, uri);
      setCustomPhoto(uri);
      setImgError(false);
    }
  };

  const removePhoto = async () => {
    await setExercisePhoto(exercise.id, null);
    setCustomPhoto(null);
  };

  const pickVideo = async () => {
    Haptics.selectionAsync();
    const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) return;
    const res = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Videos,
      quality: 1,
    });
    if (!res.canceled && res.assets?.[0]?.uri) {
      const uri = res.assets[0].uri;
      await setExerciseVideo(exercise.id, uri);
      setCustomVideo(uri);
    }
  };

  const removeVideo = async () => {
    await setExerciseVideo(exercise.id, null);
    setCustomVideo(null);
  };

  const openPlayer = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    // Se l'utente ha caricato un video personale, riproduci quello.
    if (customVideo) {
      setVideoOpen(true);
      try {
        player.play();
      } catch (_) {}
    } else {
      setPlayerOpen(true);
    }
  };

  const closeVideo = () => {
    try {
      player.pause();
    } catch (_) {}
    setVideoOpen(false);
  };

  return (
    <View>
      <Pressable
        style={[styles.banner, glowActive && glowShadow(theme.glow, 12)]}
        onPress={() => showImage && setViewerOpen(true)}
      >
        {showImage ? (
          <Image
            source={{ uri: imageUri }}
            style={styles.image}
            resizeMode="cover"
            onError={() => setImgError(true)}
          />
        ) : (
          <View style={styles.placeholder}>
            <MaterialCommunityIcons
              name={categoryIcon(exercise?.category)}
              size={72}
              color={theme.colors.primary}
              style={{ opacity: 0.9 }}
            />
            <Text style={styles.placeholderText} numberOfLines={1}>
              {exercise?.name}
            </Text>
          </View>
        )}

        <TouchableOpacity
          style={[styles.playBtn, glowActive && glowShadow(theme.glow, 14)]}
          onPress={openPlayer}
          activeOpacity={0.85}
        >
          <MaterialCommunityIcons name="play" size={34} color={theme.colors.bg} />
        </TouchableOpacity>
      </Pressable>

      <View style={styles.actions}>
        <Text style={styles.caption}>
          {customVideo ? '▶ Il tuo video personale' : '▶ Play per la dimostrazione'}
        </Text>
        <View style={styles.actionBtns}>
          <TouchableOpacity style={styles.smallBtn} onPress={pickPhoto}>
            <MaterialCommunityIcons name="camera-plus" size={16} color={theme.colors.primary} />
            <Text style={styles.smallBtnText}>Foto</Text>
          </TouchableOpacity>
          {customPhoto && (
            <TouchableOpacity style={styles.smallBtn} onPress={removePhoto}>
              <MaterialCommunityIcons name="restore" size={16} color={theme.colors.textMuted} />
              <Text style={styles.smallBtnText}>Ripristina</Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity style={styles.smallBtn} onPress={pickVideo}>
            <MaterialCommunityIcons name="video-plus" size={16} color={theme.colors.primary} />
            <Text style={styles.smallBtnText}>Video</Text>
          </TouchableOpacity>
          {customVideo && (
            <TouchableOpacity style={styles.smallBtn} onPress={removeVideo}>
              <MaterialCommunityIcons name="video-off" size={16} color={theme.colors.textMuted} />
              <Text style={styles.smallBtnText}>Rimuovi</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>

      {/* Player video in-app */}
      <Modal visible={playerOpen} animationType="slide" onRequestClose={() => setPlayerOpen(false)}>
        <View style={styles.playerContainer}>
          <View style={styles.playerHeader}>
            <Text style={styles.playerTitle} numberOfLines={1}>
              {exercise?.name}
            </Text>
            <TouchableOpacity onPress={() => setPlayerOpen(false)} style={styles.closeBtn}>
              <MaterialCommunityIcons name="close" size={26} color={theme.colors.text} />
            </TouchableOpacity>
          </View>
          <WebView
            source={{ uri: media.playUrl }}
            style={{ flex: 1, backgroundColor: '#000' }}
            allowsFullscreenVideo
            mediaPlaybackRequiresUserAction={false}
            startInLoadingState
            renderLoading={() => (
              <View style={styles.loading}>
                <ActivityIndicator size="large" color={theme.colors.primary} />
              </View>
            )}
          />
        </View>
      </Modal>

      {/* Player video personale (nativo, expo-video) */}
      <Modal visible={videoOpen} animationType="slide" onRequestClose={closeVideo}>
        <View style={styles.playerContainer}>
          <View style={styles.playerHeader}>
            <Text style={styles.playerTitle} numberOfLines={1}>
              {exercise?.name} · video personale
            </Text>
            <TouchableOpacity onPress={closeVideo} style={styles.closeBtn}>
              <MaterialCommunityIcons name="close" size={26} color={theme.colors.text} />
            </TouchableOpacity>
          </View>
          <View style={{ flex: 1, justifyContent: 'center', backgroundColor: '#000' }}>
            {customVideo && (
              <VideoView
                player={player}
                style={{ width: '100%', height: '100%' }}
                allowsFullscreen
                nativeControls
                contentFit="contain"
              />
            )}
          </View>
        </View>
      </Modal>

      {/* Visore immagine a schermo intero */}
      <Modal visible={viewerOpen} transparent animationType="fade" onRequestClose={() => setViewerOpen(false)}>
        <Pressable style={styles.viewer} onPress={() => setViewerOpen(false)}>
          <Image source={{ uri: imageUri }} style={styles.viewerImg} resizeMode="contain" />
          <TouchableOpacity style={styles.viewerClose} onPress={() => setViewerOpen(false)}>
            <MaterialCommunityIcons name="close" size={30} color="#fff" />
          </TouchableOpacity>
        </Pressable>
      </Modal>
    </View>
  );
}

const makeStyles = (c) =>
  StyleSheet.create({
    banner: {
      height: 190,
      borderRadius: radius.lg,
      backgroundColor: c.cardAlt,
      borderWidth: 1,
      borderColor: c.border,
      overflow: 'hidden',
      alignItems: 'center',
      justifyContent: 'center',
    },
    image: { ...StyleSheet.absoluteFillObject, width: '100%', height: '100%' },
    placeholder: { alignItems: 'center', justifyContent: 'center' },
    placeholderText: {
      color: c.textMuted,
      fontWeight: '700',
      marginTop: spacing.sm,
      fontSize: 16,
    },
    playBtn: {
      position: 'absolute',
      width: 68,
      height: 68,
      borderRadius: 34,
      backgroundColor: c.primary,
      alignItems: 'center',
      justifyContent: 'center',
      paddingLeft: 4,
    },
    actions: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginTop: spacing.sm,
    },
    caption: { color: c.textMuted, fontSize: 12 },
    actionBtns: { flexDirection: 'row', gap: spacing.sm },
    smallBtn: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: 4,
      backgroundColor: c.card,
      borderRadius: radius.sm,
      paddingHorizontal: spacing.sm,
      paddingVertical: spacing.xs,
      borderWidth: 1,
      borderColor: c.border,
    },
    smallBtnText: { color: c.text, fontSize: 12, fontWeight: '600' },
    playerContainer: { flex: 1, backgroundColor: '#000' },
    playerHeader: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: c.card,
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.md,
      paddingTop: spacing.lg,
    },
    playerTitle: { color: c.text, fontSize: 16, fontWeight: '700', flex: 1 },
    closeBtn: { padding: spacing.xs },
    loading: {
      ...StyleSheet.absoluteFillObject,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#000',
    },
    viewer: {
      flex: 1,
      backgroundColor: '#000000ee',
      alignItems: 'center',
      justifyContent: 'center',
    },
    viewerImg: { width: '100%', height: '80%' },
    viewerClose: { position: 'absolute', top: 40, right: 20, padding: spacing.sm },
  });
