/// Провайдер Места, ПМ
library;

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import '/models/place.dart';

final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  //* Метод записи данных в ДБ
  Future<void> addPlace(
    String title,
    File image,
    PlaceLocation location,
  ) async {
    var getDate = DateTime.now().toString();

    // Открыть базу
    final db = await getDatabase();

    // Задать путь сохранения
    final appDir = await syspaths.getApplicationDocumentsDirectory();

    // Задать базовое имя файла
    final filename = path.basename(image.path);

    // Скопировать изображение, чтобы поместить его в каталог
    final copiedImage = await image.copy('${appDir.path}/$filename');

    // Задать модель нового Места
    final Place newPlace = Place(
      title: title,
      date: getDate,
      image: copiedImage,
      location: location,
    );

    // Записать в БД все данные по новому месту
    db.insert('best_places', {
      'title': newPlace.title,
      'date': newPlace.date,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
    state = [newPlace, ...state];
  }

  //* Метод извлечения данных из БД
  Future<void> loadPlaces() async {
    List<Place> result;
    result = await getData();
    state = result;
  }

  //* Метод удаления данных из БД
  Future removePlace(String date) async {
    final db = await getDatabase();
    List<Place> result;
    await db.delete(
      'best_places',
      where: 'date = ?',
      whereArgs: [date],
    );
    await db.close();
    result = await getData();
    state = result;
  }

  //* Метод очистки БД
  Future<void> clearDB() async {
    List<Place> result;

    await sql.deleteDatabase("/data/user/0/com.example.favorite_places_13/databases/100_places.db");
    result = await getData();
    state = result;
  }

  //* Метод редакции названия
  /* 
  Требуются два параметра: 
      ЧТО обновлять (значение: newTitle) и
      ГДЕ обновлять (идентификатор: date) 
  */
  Future<void> updateTitle(
    String newTitle,
    String date,
  ) async {
    final db = await getDatabase();
    List<Place> result;
    /* 
    Функция _update_ содержит: 
        имя таблицы, 
        карту с новым значением в колонке 'title', 
        идентификатор, по которому вносится обновление,
        значение идентификатора 
    */
    await db.update(
      'best_places',
      {'title': newTitle}, //^ новое значение (ЧТО изменить?)
      where: "date = ?", //^ для какой строки (ГДЕ изменить?)
      whereArgs: [date],
    );
    await db.close();
    result = await getData();
    state = result;
  }

  //* Метод редакции местоположения
  Future<void> updateLocation(
    String newLat,
    String newLng,
    String addr,
    String date,
  ) async {
    final db = await getDatabase();
    List<Place> result;

    await db.update(
      'best_places',
      {
        'lat': newLat,
        'lng': newLng,
        'address': addr,
      },
      where: "date = ?",
      whereArgs: [date],
    );
    await db.close();
    result = await getData();
    state = result;
  }
}

//| МЕТОДЫ внутреннего значения                >

//* Запрос данных из БД
Future<List<Place>> getData() async {
  final db = await getDatabase();
  final getData = await db.query('best_places');
  final places = getData
      .map(
        (row) => Place(
            title: row['title'] as String,
            date: row['date'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            )),
      )
      .toList();
  return places;
}

//* Инициализация БД
Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  // print('DB Path ======>> $dbPath');
  /* полученный адрес:
  /data/user/0/com.example.favorite_places_13/databases
  */
  // Directory? extDir = await syspaths.getExternalStorageDirectory();
  // print('DB extDir ======>> $extDir');
  /* полученный адрес:
  /storage/emulated/0/Android/data/com.example.favorite_places_13/files
  */

  final db = await sql.openDatabase(
    path.join(dbPath, '100_places.db'),
    onCreate: (db, version) => db.execute('''
        CREATE TABLE best_places(
          title TEXT, 
          date TEXT PRIMARY KEY, 
          image TEXT, 
          lat REAL, 
          lng REAL, 
          address TEXT
        )
      '''),
    version: 1,
  );
  return db;
}
