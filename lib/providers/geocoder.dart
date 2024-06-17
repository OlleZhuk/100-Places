/// Геокодер Яндекс.
/// На входе координаты, на выходе - адрес
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

final addressProvider = StateNotifierProvider<GetAddress, String>(
  (ref) => GetAddress(),
);

class GetAddress extends StateNotifier<String> {
  GetAddress() : super('');

//* Метод получения локации
  Future<void> getAddress(
    double lat,
    double lng,
  ) async {
    String address = '';
    final geo = YandexGeocoder(apiKey: '60c7f14a-95e8-4d8b-9b03-b17e48c72f40');

    const error = '⛔НЕПРЕДВИДЕННАЯ ОШИБКА!';
    const err403 = '⛔АДРЕС НЕ ПОЛУЧЕН!\n'
        'Исчерпан ежедневный лимит на выдачу адресов. Пожалуйста, введите адрес вручную или повторите попытку завтра.';
    const noInternet = '⛔АДРЕС НЕ ПОЛУЧЕН!\n'
        'Нет соединения с интернетом!';

    try {
      final GeocodeResponse gettingAddress = await geo.getGeocode(
        GeocodeRequest(
            geocode: PointGeocode(
          latitude: lat,
          longitude: lng,
        )),
      );
      address = gettingAddress.firstAddress?.formatted ?? 'null';

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

/// Поставщик стрим-адреса для ЭК и ЭДМ
///
final streamAddressProvider = StreamProvider<String>((ref) {
  String address = ref.watch(addressProvider);
  return Stream.value(address);
});
