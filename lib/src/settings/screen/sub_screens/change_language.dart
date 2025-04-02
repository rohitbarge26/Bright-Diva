import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../multi_language/model/language_list_response.dart';
import '../../../../utils/language_utils.dart';
import '../../../../utils/pref_key.dart';
import '../../../../utils/prefs.dart';
import '../../../../widgets/custom_text.dart';

class LanguageSelection extends StatefulWidget {
  final VoidCallback onBackArrowTap;

  const LanguageSelection({super.key, required this.onBackArrowTap});

  @override
  State<LanguageSelection> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  String? selectedLanguageId;
  List<LanguageListData>? languageList;
  Color buttonColor = const Color(0xFFF85A5A);
  String? selectedCultureCode = Prefs.getString(HEADER_LANGUAGE).isEmpty
      ? "en-US"
      : Prefs.getString(HEADER_LANGUAGE);

  void _onButtonPressed() {
    FocusScope.of(context).requestFocus(FocusNode());
    String languageCode = selectedCultureCode!.split('-').first;
    Prefs.setHeaderLangString(HEADER_LANGUAGE, selectedCultureCode);
    Prefs.setLocalLangString(LOCAL_LANGUAGE, languageCode);
    Prefs.setUILangString(SELECTED_LANGUAGE, selectedCultureCode);
    // Use the Provider to get the LanguageNotifier instance
    LanguageNotifier languageNotifier = context.read<LanguageNotifier>();
    languageNotifier.changeLanguage(languageCode);
    widget.onBackArrowTap();
  }

  @override
  void initState() {
    languageList = LanguageListResponse.getStaticLanguages().data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 55.0, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      widget.onBackArrowTap();
                    },
                    child: SvgPicture.asset(
                      'assets/icons/back_arrow_icon.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    text: AppLocalizations.of(context)!.prLanguage,
                    fontSize: 20,
                    desiredLineHeight: 28,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.02,
                    color: const Color(0xFF171717),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomText(
                text: AppLocalizations.of(context)!.prSelectLanguage,
                fontSize: 16,
                desiredLineHeight: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.16,
                color: const Color(0xFF171717)),
            CustomText(
                text: AppLocalizations.of(context)!.prLangInstruction,
                fontSize: 14,
                desiredLineHeight: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: const Color(0xFF737373)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: languageList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final language = languageList![index];
                    final isChecked = language.cultureCode == selectedCultureCode;
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: isChecked
                              ? ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFFB8888)),
                                  borderRadius: BorderRadius.circular(8),
                                ))
                              : ShapeDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: language.name!,
                                  fontSize: 14,
                                  desiredLineHeight: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: isChecked
                                      ? const Color(0xFF262626)
                                      : const Color(0xFF737373),
                                  letterSpacing: -0.14,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            trailing: isChecked
                                ? SvgPicture.asset(
                                    'assets/images/radio_check_circle.svg',
                                    height: 24,
                                    width: 24,
                                  )
                                : SvgPicture.asset(
                                    'assets/images/radio_circle.svg',
                                    height: 24,
                                    width: 24,
                                  ),
                            onTap: () {
                              setState(() {
                                selectedLanguageId = language.id;
                                selectedCultureCode = language.cultureCode;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: buttonColor,
              ),
              child: TextButton(
                onPressed: /*isButtonEnabled ?*/
                    _onButtonPressed /*: null*/,
                child: CustomText(
                    text: AppLocalizations.of(context)!.prEdtSaveChanges,
                    fontSize: 16,
                    desiredLineHeight: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
