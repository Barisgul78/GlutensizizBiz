import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as du;
import '../../../../core/widgets/custom_button.dart';

// Tanı ayı+yılı seçimi için alttan açılan iki tekerlekli seçici (3. parti paket yok)
Future<DateTime?> showDiagnosisDatePicker(BuildContext context) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: kOnPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => const _DiagnosisDatePickerSheet(),
  );
}

class _DiagnosisDatePickerSheet extends StatefulWidget {
  const _DiagnosisDatePickerSheet();

  @override
  State<_DiagnosisDatePickerSheet> createState() => _DiagnosisDatePickerSheetState();
}

class _DiagnosisDatePickerSheetState extends State<_DiagnosisDatePickerSheet> {
  static final _now = DateTime.now();
  static final _years = List<int>.generate(80, (i) => _now.year - i); // azalan, gelecek yıl yok

  late int _selectedYear = _years.first;
  late int _selectedMonth = _now.month;
  late final FixedExtentScrollController _monthController =
      FixedExtentScrollController(initialItem: _selectedMonth - 1);

  List<int> get _availableMonths {
    final maxMonth = _selectedYear == _now.year ? _now.month : 12;
    return List<int>.generate(maxMonth, (i) => i + 1);
  }

  void _onYearChanged(int index) {
    final newYear = _years[index];
    final months = _selectedYear == newYear
        ? _availableMonths
        : List<int>.generate(newYear == _now.year ? _now.month : 12, (i) => i + 1);
    setState(() {
      _selectedYear = newYear;
      if (_selectedMonth > months.length) {
        _selectedMonth = months.length;
        _monthController.jumpToItem(_selectedMonth - 1);
      }
    });
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final months = _availableMonths;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kOutlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tanı Tarihini Seç',
              style: GoogleFonts.plusJakartaSans(
                color: kOnSurface,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: 216,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: _monthController,
                      onSelectedItemChanged: (index) =>
                          setState(() => _selectedMonth = months[index]),
                      children: months
                          .map((m) => Center(
                                child: Text(
                                  du.monthName(m),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: kOnSurface,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      onSelectedItemChanged: _onYearChanged,
                      children: _years
                          .map((y) => Center(
                                child: Text(
                                  '$y',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: kOnSurface,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppButton(
                label: 'Kaydet',
                onPressed: () => Navigator.of(context)
                    .pop(DateTime(_selectedYear, _selectedMonth, 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
