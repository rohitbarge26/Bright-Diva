import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import '../multi_language/model/language_list_response.dart';
import '../utils/language_utils.dart';
import '../utils/pref_key.dart';
import '../utils/prefs.dart';
import 'custom_text.dart';

class LanguageSelectionDialog extends StatefulWidget {
  final VoidCallback onChangeLanguageTap;
  final List<LanguageListData>? data;

  const LanguageSelectionDialog(
      {super.key, required this.onChangeLanguageTap, required this.data});

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  String? selectedLanguageId;
  String? selectedCultureCode;
  bool isButtonEnabled = false;
  Color buttonColor = const Color(0xFFFDBABA);

  void _updateButtonColor() {
    setState(() {
      bool isRadioLanguageSelected = selectedLanguageId?.isNotEmpty ?? false;
      isButtonEnabled = isRadioLanguageSelected;
      buttonColor =
          isButtonEnabled ? const Color(0xFFF85A5A) : const Color(0xFFFDBABA);
    });
  }

  void _onButtonPressed() {
    FocusScope.of(context).requestFocus(FocusNode());
    String languageCode = selectedCultureCode!.split('-').first;
    Prefs.setHeaderLangString(HEADER_LANGUAGE, selectedCultureCode);
    Prefs.setLocalLangString(LOCAL_LANGUAGE, languageCode);
    Prefs.setUILangString(SELECTED_LANGUAGE, selectedCultureCode);
    // Use the Provider to get the LanguageNotifier instance
    LanguageNotifier languageNotifier = context.read<LanguageNotifier>();
    languageNotifier.changeLanguage(languageCode);
    widget.onChangeLanguageTap();
  }

  @override
  Widget build(BuildContext context) {
    _updateButtonColor();
    return AlertDialog(
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          CustomText(
            textAlign: TextAlign.center,
            text: AppLocalizations.of(context)!.labelSelectLanguage,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            desiredLineHeight: 28,
            letterSpacing: -0.40,
            color: const Color(0xFF111827),
          ),
          const SizedBox(height: 16.0),
          DropdownButton<String>(
            value: selectedLanguageId,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF727272),
              letterSpacing: -0.28,
              fontFamily: "Inter",
            ),
            hint: Text(
              AppLocalizations.of(context)!.labelSelectLanguage,
              style: const TextStyle(
                color: Color(0xFF727272),
                fontSize: 14,
                fontFamily: "Inter",
                letterSpacing: -0.28,
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguageId = newValue;
                LanguageListData? selectedLanguage = widget.data?.firstWhere(
                  (language) => language.id == newValue,
                  orElse: () =>
                      LanguageListData(id: '', name: '', cultureCode: ''),
                );
                selectedCultureCode = selectedLanguage?.cultureCode;
              });
            },
            items: (widget.data ?? [])
                .map<DropdownMenuItem<String>>((LanguageListData language) {
              return DropdownMenuItem<String>(
                value: language.id,
                child: CustomText(
                  text: language.name!,
                  fontSize: 14,
                  desiredLineHeight: 20,
                  fontFamily: 'Intel',
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF262626),
                  textAlign: TextAlign.start,
                ),
              );
            }).toList(),
            isExpanded: true,
            underline: Container(),
          ),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12, bottom: 32.0),
            child: InkWell(
              onTap: isButtonEnabled ? _onButtonPressed : null,
              child: Container(
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: buttonColor,
                ),
                child: CustomText(
                  text: AppLocalizations.of(context)!.labelConfirm,
                  fontSize: 16,
                  desiredLineHeight: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ]);
  }
}
