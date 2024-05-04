import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ПРОВАЙДЕРЫ

/// Для отображения корректного названия на ЭИМ
final isEditTitleProvider = StateProvider<bool>((ref) => false);

/// Поставщик названия для ЭИМ
final titleProvider = StateProvider<String>((ref) => '');

/// Для отображения корректного адреса на ЭИМ
final isEditLocationProvider = StateProvider<bool>((ref) => false);

/// Для подтверждения выбранной локации на ЭК
final isConfirmedLocationProvider = StateProvider<bool>((ref) => false);

/// Для разделения режимов создания и редактирования локации
final isCreatingLocationProvider = StateProvider<bool>((ref) => false);

/// Поставщик даты для обеспечения обновлений БД
final dateProvider = StateProvider<String>((ref) => '');
