/// ПРОВАЙДЕРЫ
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

//* ФЛАГИ _bool_ ----------------------------------

/// Флаг для корректного названия на ЭИМ
final isEditTitleProvider = StateProvider<bool>((ref) => false);

/// Флаг для режима создания локации
final isCreatingLocationProvider = StateProvider<bool>((ref) => false);

/// Флаг для режима редактирования локации
final isEditLocationProvider = StateProvider<bool>((ref) => false);

/// Флаг для подтверждения выбранной локации на ЭК
final onGetAddressProvider = StateProvider<bool>((ref) => false);

//* _String_ ДАННЫЕ ----------------------------------

/// Поставщик названия для ЭИМ (при редактировании)
final titleProvider = StateProvider<String>((ref) => '');

/// Поставщик даты для обеспечения обновлений БД
final dateProvider = StateProvider<String>((ref) => '');

/// Поставщик адреса, набранного вручную
final manualAddressProvider = StateProvider<String>((ref) => '');

/// Поставщик switch-case источника местоположения
final selectedSourseProvider = StateProvider<String>((ref) => '');

//* ДРУГОЕ ----------------------------------

/// Поставщик файла изображения
final imageFileProvider = StateProvider<File?>((ref) => null);
