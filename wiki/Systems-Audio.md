# Audio System

## Audio buses
- Music bus: background music
- SFX bus: sound effects

## Audio manager
- Centralized click sound playback for UI interactions.
- Instantiates a temporary AudioStreamPlayer and frees it after playback.

## Volume controls
- Music and SFX volumes are user-configurable.
- Volume settings are saved and loaded on startup.
- Sliders write directly to AudioServer bus volume in linear-to-db conversion.

## Typical flows
- Menu button press: AudioManager plays click on SFX bus.
- Music track change: arena transitions swap the AudioStream and restart playback.
