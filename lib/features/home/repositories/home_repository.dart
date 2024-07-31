import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/home/model/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, String>> uploadSong(
      {required File selectedAudio,
      required File selectedThumbnail,
      required String songName,
      required String artist,
      required String hexCode,
      required String token}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstants.serverUrl}/song/upload'),
      );

      request
        ..files.addAll([
          await http.MultipartFile.fromPath('song', selectedAudio.path),
          await http.MultipartFile.fromPath(
              'thumbnail', selectedThumbnail.path),
        ])
        ..fields.addAll({
          'artist': artist,
          'song_name': songName,
          'hex_code': hexCode,
        })
        ..headers.addAll(
          {'auth-token': token},
        );
      final response = await request.send();
      if (response.statusCode != 201) {
        return Left(AppFailure(await response.stream.bytesToString()));
      }
      return Right(await response.stream.bytesToString());
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getAllSongs({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstants.serverUrl}/song/list'),
        headers: {
          'auth-token': token,
        },
      );
      var resBodyMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];
      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, bool>> favSong({
    required String token,
    required String songId,
  }) async {
    try {
      final response = await http.post(
        body: jsonEncode({'song_id': songId}),
        Uri.parse('${ServerConstants.serverUrl}/song/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'auth-token': token,
        },
      );
      var resBodyMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(resBodyMap['message']);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getFavSongs({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstants.serverUrl}/song/list/favorites'),
        headers: {
          'auth-token': token,
        },
      );
      var resBodyMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];
      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map['song']));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
