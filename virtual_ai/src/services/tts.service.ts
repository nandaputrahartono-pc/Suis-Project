import { EdgeTTS } from 'edge-tts-universal';
import type { SynthesisResult, WordBoundary } from 'edge-tts-universal';

/**
 * TTS Service — Generate audio dari teks menggunakan Microsoft Edge TTS.
 * 
 * Voice: id-ID-GadisNeural (perempuan Indonesia)
 * Output: MP3 audio buffer + word timing data untuk subtitle sync
 */

const VOICE = 'id-ID-GadisNeural';

/**
 * Hasil TTS termasuk audio dan data timing kata.
 */
export interface TTSResult {
  audio: Buffer;
  wordBoundaries: Array<{
    offset: number;   // milliseconds dari awal audio
    duration: number; // milliseconds durasi kata
    text: string;     // teks kata
  }>;
}

/**
 * Generate audio MP3 dan word timing dari teks.
 * 
 * @param text - Teks yang akan dikonversi ke suara
 * @returns TTSResult dengan audio buffer dan word boundary data
 */
export async function generateSpeech(text: string): Promise<TTSResult> {
  const tts = new EdgeTTS(text, VOICE);
  const result: SynthesisResult = await tts.synthesize();
  
  // Convert Blob to Buffer
  const arrayBuffer = await result.audio.arrayBuffer();
  const audioBuffer = Buffer.from(arrayBuffer);
  
  // Convert word boundaries (100-nanosecond units → milliseconds)
  const wordBoundaries = (result.subtitle as WordBoundary[]).map((wb) => ({
    offset: Math.round(wb.offset / 10000),    // 100ns → ms
    duration: Math.round(wb.duration / 10000), // 100ns → ms
    text: wb.text,
  }));

  return {
    audio: audioBuffer,
    wordBoundaries,
  };
}
