// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

class SongModel {
  final String id;
  final String song_name;
  final String artist;
  final String thumbnail_url;
  final String song_url;
  final String hex_code;

  SongModel({
    required this.id,
    required this.song_name,
    required this.artist,
    required this.thumbnail_url,
    required this.song_url,
    required this.hex_code,
  });

  SongModel copyWith({
    String? id,
    String? song_name,
    String? artist,
    String? thumbnail_url,
    String? song_url,
    String? hex_code,
  }) {
    return SongModel(
      id: id ?? this.id,
      song_name: song_name ?? this.song_name,
      artist: artist ?? this.artist,
      thumbnail_url: thumbnail_url ?? this.thumbnail_url,
      song_url: song_url ?? this.song_url,
      hex_code: hex_code ?? this.hex_code,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'song_name': song_name,
      'artist': artist,
      'thumbnail_url': thumbnail_url,
      'song_url': song_url,
      'hex_code': hex_code,
    };
  }

  /// Fix garbled encoding like "ð" by re-decoding as UTF-8
  static String fixEncoding(String input) {
    final bytes = latin1.encode(input); // Re-encode assuming wrong Latin-1
    return utf8.decode(bytes); // Decode properly as UTF-8
  }

  /// Detect if a string is garbled (mojibake)
  static bool isGarbled(String input) {
    // Very basic check for known mojibake characters
    return input.contains('ð') || input.contains('�');
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    final rawSongName = map['song_name']?.toString() ?? '';
    final rawArtist = map['artist']?.toString() ?? '';

    return SongModel(
      id: map['id']?.toString() ?? '',
      song_name:
          isGarbled(rawSongName) ? fixEncoding(rawSongName) : rawSongName,
      artist: isGarbled(rawArtist) ? fixEncoding(rawArtist) : rawArtist,
      thumbnail_url: map['thumbnail_url']?.toString() ?? '',
      song_url: map['song_url']?.toString() ?? '',
      hex_code: map['hex_code']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(String source) =>
      SongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SongModel(id: $id, song_name: $song_name, artist: $artist, thumbnail_url: $thumbnail_url, song_url: $song_url, hex_code: $hex_code)';
  }

  @override
  bool operator ==(covariant SongModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.song_name == song_name &&
        other.artist == artist &&
        other.thumbnail_url == thumbnail_url &&
        other.song_url == song_url &&
        other.hex_code == hex_code;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        song_name.hashCode ^
        artist.hashCode ^
        thumbnail_url.hashCode ^
        song_url.hashCode ^
        hex_code.hashCode;
  }
}
