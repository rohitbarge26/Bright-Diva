import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/src/MIS_report/bloc/mis_bloc.dart';
import 'package:frequent_flow/src/MIS_report/bloc/mis_state.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/response_status.dart';
import '../../../widgets/calendar_job_filter_dialog.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../../customer_management/bloc/customer_bloc.dart';
import '../../customer_management/bloc/customer_event.dart';
import '../../customer_management/bloc/customer_state.dart';
import '../../customer_management/model/get_customer.dart';
import '../bloc/mis_event.dart';

class MisReport extends StatefulWidget {
  const MisReport({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<MisReport> createState() => _MisReportState();
}

class _MisReportState extends State<MisReport> {
  final _formMISReportKey = GlobalKey<FormState>();
  late DateTime selectedFirstDate = DateTime.now();
  late DateTime selectedLastDate = DateTime.now();
  String? _selectedData = 'Invoice'; // Default value
  final List<String> _data = ['Invoice', 'Cash', 'Order'];
  List<Customers>? customerList;
  String? selectedCustomer;
  bool isSubmitting = false;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    BlocProvider.of<CustomerBloc>(context, listen: false)
        .add(const GetCustomerList());
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android-specific storage permission handling
      if (await Permission.manageExternalStorage.isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
      } else {
        var status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          setState(() {
            _isPermissionGranted = true;
          });
        } else {
          print("Storage permission denied");
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      }
    } else {
      // iOS automatically grants access to app directories
      setState(() {
        _isPermissionGranted = true;
      });

      // Optional: Request photo library permission if you need to save to Photos
      // var photoStatus = await Permission.photos.request();
      // if (photoStatus.isGranted) {
      //   print("Photos permission granted");
      // }
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getDownloadPath() async {
    String downloadsPath =
        "/storage/emulated/0/Download/KFT/"; // Change "MyApp" to your app's name

    Directory appDirectory = Directory(downloadsPath);

    if (!await appDirectory.exists()) {
      await appDirectory.create(
          recursive: true); // Create the folder if it doesn't exist
    }

    return downloadsPath;
  }

  Future<void> downloadAndSaveFile(String url) async {
    try {
      // For iOS, we don't need storage permission for downloads directory
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          print('Permission :: ${status.isGranted}');
          return;
        }
      }

      // Get the appropriate directory based on platform
      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Define the file path
      String fileName = url.split('/').last;
      String filePath = '${directory.path}/$fileName';

      // Download the file using Dio
      Dio dio = Dio();
      await dio.download(url, filePath);

      // For iOS, we'll use the documents directory directly
      String newPath;
      if (Platform.isAndroid) {
        newPath = "${await getDownloadPath()}MIS_Report_$_selectedData.xlsx";
      } else {
        newPath = '${directory.path}/MIS_Report_$_selectedData.xlsx';
      }

      File file = File(filePath);
      await file.copy(newPath);

      // Show download complete message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download Completed: $newPath")),
      );

      // On iOS, we can offer to open the document in other apps
      if (Platform.isIOS) {
        await OpenFile.open(newPath);
      }
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MisBloc, MisState>(
      listener: (BuildContext context, MisState state) {
        if (state is MisInitialState) {
          const CircularProgressIndicator();
        } else if (state is MisLoadedState) {
          int code = state.misDataResponse?.statusCode ?? 0;
          print('Code : $code');
          setState(() {
            isSubmitting = false;
          });
          if (code == SUCCESS) {
            String url = state.misDataResponse!.url!;
            print("URL : $url");
            downloadAndSaveFile(url); // Call the download function
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ErrorAlertDialog(
                    alertLogoPath: 'assets/icons/error_icon.svg',
                    status: AppLocalizations.of(context)!.unableToProcess,
                    statusInfo:
                        AppLocalizations.of(context)!.somethingWentWrong,
                    buttonText: AppLocalizations.of(context)!.btnOkay,
                    onPress: () {
                      Navigator.of(context).pop();
                    }));
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 68, right: 16.0, left: 16),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            widget.onBackTap();
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
                          text: AppLocalizations.of(context)!.misReport,
                          fontSize: 20,
                          desiredLineHeight: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.02,
                          color: const Color(0xFF171717),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]),
                const SizedBox(
                  height: 12,
                ),
                Form(
                    key: _formMISReportKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Column(children: [
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CalendarJobFilterDialog(
                                        currentDate: selectedFirstDate,
                                        startDate: DateTime.utc(2023),
                                      );
                                    }).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedFirstDate = value;
                                    });
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .startDate,
                                            fontSize: 14,
                                            desiredLineHeight: 24,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.28,
                                            color: const Color(0xFF737373),
                                          ),
                                          Opacity(
                                            opacity: 0.50,
                                            child: CustomText(
                                              text: DateFormat('EEEE, MMMM d')
                                                  .format(selectedFirstDate),
                                              fontSize: 14,
                                              desiredLineHeight: 20,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.28,
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ]),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_right,
                                    size: 24,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(
                              height: 1,
                              color: Color(0xFFE2E3E6),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CalendarJobFilterDialog(
                                          currentDate: selectedFirstDate,
                                          startDate: selectedFirstDate);
                                    }).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedLastDate = value;
                                    });
                                  }
                                });
                              },
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .endDate,
                                              fontSize: 14,
                                              desiredLineHeight: 24,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.28,
                                              color: const Color(0xFF737373),
                                            ),
                                            Opacity(
                                              opacity: 0.50,
                                              child: CustomText(
                                                text: DateFormat('EEEE, MMMM d')
                                                    .format(selectedLastDate),
                                                fontSize: 14,
                                                desiredLineHeight: 20,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.28,
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ]),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 24,
                                      color: Colors.black,
                                    )
                                  ]),
                            ),
                            const SizedBox(height: 16),
                            const Divider(
                              height: 1,
                              color: Color(0xFFE2E3E6),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!
                                      .customerName,
                                  fontSize: 18,
                                  desiredLineHeight: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF171717),
                                ),
                                const SizedBox(height: 5),
                                BlocBuilder<CustomerBloc, CustomerState>(
                                  builder: (context, state) {
                                    if (state is CustomerListInitialState) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (state
                                        is CustomerListLoadedState) {
                                      int code = state.getCustomerListResponse
                                              ?.statusCode ??
                                          0;
                                      customerList = state
                                          .getCustomerListResponse?.customers;
                                      int? totalCustomer =
                                          state.getCustomerListResponse?.total;
                                      if (totalCustomer == 0) {
                                        return const SizedBox.shrink();
                                      } else {
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 15),
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFE2E3E6)),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: DropdownSearch<Customers>(
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .searchCustomer,
                                                ),
                                              ),
                                            ),
                                            items: customerList ?? [],
                                            itemAsString: (Customers u) =>
                                                '${u.companyName} - ${u.city}',
                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .selectCustomer,
                                                border: InputBorder.none,
                                              ),
                                            ),
                                            onChanged: (Customers? newValue) {
                                              setState(() {
                                                selectedCustomer = newValue?.id;
                                              });
                                            },
                                          ),
                                        );
                                      }
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .dataSelection,
                                    fontSize: 18,
                                    desiredLineHeight: 24,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF171717),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: DropdownButton<String>(
                                        value: _selectedData,
                                        hint: const Text("Select Currency"),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedData = newValue;
                                          });
                                        },
                                        items: _data
                                            .map<DropdownMenuItem<String>>(
                                                (String currency) {
                                          return DropdownMenuItem<String>(
                                            value: currency,
                                            child: Text(currency),
                                          );
                                        }).toList(),
                                        underline: const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ]),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () async {
                                String startDateFormatted = '';
                                String endDateFormatted = '';
                                if (selectedFirstDate
                                    .isAfter(selectedLastDate)) {
                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ErrorAlertDialog(
                                        alertLogoPath:
                                            'assets/icons/error_icon.svg',
                                        status: 'Invalid last date',
                                        statusInfo:
                                            'First date cannot be a date that comes after the last date.',
                                        buttonText:
                                            AppLocalizations.of(context)!
                                                .btnOkay,
                                        onPress: () {
                                          Navigator.of(context).pop();
                                          return;
                                        },
                                      );
                                    },
                                  );
                                  return;
                                }
                                startDateFormatted = DateFormat('yyyy-MM-dd')
                                    .format(selectedFirstDate);
                                endDateFormatted = DateFormat('yyyy-MM-dd')
                                    .format(selectedLastDate);
                                //fetch pdf file data response

                                if (selectedCustomer == '') {
                                  BlocProvider.of<MisBloc>(context)
                                      .add(MISFilterEvent(
                                    type: _selectedData!,
                                    fromDate: startDateFormatted,
                                    toDate: endDateFormatted,
                                  ));
                                } else {
                                  BlocProvider.of<MisBloc>(context).add(
                                      MISFilterEvent(
                                          type: _selectedData!,
                                          fromDate: startDateFormatted,
                                          toDate: endDateFormatted,
                                          customerId: selectedCustomer ?? ''));
                                }
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF85A5A),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.downloadExcel,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ])),
                        ])),
              ]),
        ),
      ),
    );
  }
}
