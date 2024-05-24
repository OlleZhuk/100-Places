/// Геокодер Яндекс
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

final addressProvider = StateNotifierProvider<GetMapAddress, String>(
  (ref) => GetMapAddress(),
);

class GetMapAddress extends StateNotifier<String> {
  GetMapAddress() : super('');

//* Метод получения локации
  Future<void> getAddress(
    double lat,
    double lng,
  ) async {
    String address = '';
    const error = '⛔НЕПРЕДВИДЕННАЯ ОШИБКА!';
    const err403 = '⛔АДРЕС НЕ ПОЛУЧЕН!\n' 'Исчерпан ежедневный лимит Яндекса на выдачу адресов. Пожалуйста, введите адрес вручную или повторите попытку завтра.';
    const noInternet = '⛔АДРЕС НЕ ПОЛУЧЕН!\n' 'Проверьте соединение с интернетом!';

    final YandexGeocoder geo = YandexGeocoder(
      // apiKey: '0fc3094b-3486-45eb-a27d-8c7b62e062b3', // #4
      apiKey: '60c7f14a-95e8-4d8b-9b03-b17e48c72f40', // #3
    );

    try {
      final GeocodeResponse gettingAddress = await geo.getGeocode(
        GeocodeRequest(
            geocode: PointGeocode(
          latitude: lat,
          longitude: lng,
        )),
      );
      address = gettingAddress.firstAddress?.formatted ?? 'null';
      // print('=== ГЕОКОДЕР: адрес получен! ===');

      state = address;
      //
    } on TimeoutException catch (_) {
      state = noInternet;
    } on SocketException catch (_) {
      state = noInternet;
    } on FormatException catch (_) {
      state = error;
    } on HttpException catch (_) {
      state = error;
    } catch (_) {
      state = err403;
    }
  }
}
