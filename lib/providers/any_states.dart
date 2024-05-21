/// ПРОВАЙДЕРЫ
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Флаг для корректного названия на ЭИМ
final isEditTitleProvider = StateProvider<bool>((ref) => false);

/// Поставщик названия для ЭИМ
final titleProvider = StateProvider<String>((ref) => '');

/// Флаг для корректного адреса на ЭИМ
final isEditLocationProvider = StateProvider<bool>((ref) => false);

/// Флаг для подтверждения выбранной локации на ЭК
final isConfirmedLocationProvider = StateProvider<bool>((ref) => false);

/// Флаг для разделения режимов создания и редактирования локации
final isCreatingLocationProvider = StateProvider<bool>((ref) => false);

/// Поставщик даты для обеспечения обновлений БД
final dateProvider = StateProvider<String>((ref) => '');

/// Поставщик ручного местоположения
final manualLocationProvider = StateProvider<String>((ref) => '');

/// Поставщик switch-case источника местоположения
final sourseLocationProvider = StateProvider<String>((ref) => '');
