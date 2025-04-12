import 'dart:isolate';

import 'package:app_usage/app_usage.dart';
import 'package:control/features/bloc/get_app_bloc/get_app_bloc.dart';
import 'package:control/features/bloc/lock_bloc/lock_bloc.dart' as lb;
import 'package:control/features/pages/camera_page.dart';
import 'package:control/features/pages/timer_page.dart';
import 'package:control/features/service/lock_app_service.dart';
import 'package:control/features/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:donut_chart/donut_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:installed_apps/app_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('lock_app_service');
  List<AppInfo> apps = [];
  List<AppUsageInfo> appUsage = [];
  List<String> packages = [];
  List<String> tempPackages = [];
  late PageController controller;

  int selectedMethod = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initialize();
    controller = PageController(viewportFraction: 0.8);
  }

  void initialize() async {
    await getAllLockedApps();
    await isAccessibilityServiceEnabled();
  }

  getAllLockedApps() async {
    final result =
        (await platform.invokeMethod('getLockStatus') as List?) ?? [];
    final data = result.map<String>((e) => e.toString()).toList();
    packages.addAll(data);
    debugPrint("Result $result");
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool? result = await platform.invokeMethod(
        'isAccessibilityEnabled',
      );
      debugPrint("Accessibility service enabled: $result");
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    context.read<GetAppBloc>().add(ListAppEvent());
    return Scaffold(
      appBar: CustomAppBar(height, width),
      backgroundColor: Color.fromARGB(255, 45, 45, 45),
      body: Stack(
        // mainAxisSize: MainAxisSize.max,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 91, 85, 85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: width * 1,
                  // height: 256,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    spacing: 10,

                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 172, 172, 172),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 224,
                        width: width * 0.43,
                        margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        child: BlocBuilder<GetAppBloc, GetAppState>(
                          builder: (context, state) {
                            if (state is GetAppLoaded) {
                              late List<AppUsageInfo> data;
                              if (state.appUsage.length >= 4) {
                                data = [
                                  state.appUsage[0],
                                  state.appUsage[1],
                                  state.appUsage[2],
                                  state.appUsage[3],
                                ];
                              } else {
                                data = state.appUsage;
                              }

                              return DonutChartWidget(
                                data:
                                    data
                                        .map(
                                          (t) => DonutSectionModel(
                                            label: t.appName,
                                            value: t.usage.inMinutes.toDouble(),
                                            color:
                                                [
                                                  Colors.red,
                                                  Colors.blue,
                                                  Colors.green,
                                                  Colors.yellow,
                                                  Colors.orange,
                                                ][data.indexOf(t)],
                                          ),
                                        )
                                        .toList(),

                                size: 200,
                                strokeWidth: 30,
                                tooltipBgColor: Colors.white,
                              );
                            } else if (state is GetAppLoading) {
                              return Center(child: Text("Loading..."));
                            } else {
                              return Center(child: Text("Error"));
                            }
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 217, 217, 217),
                              borderRadius: BorderRadius.circular(10),
                            ),

                            width: width * 0.43,
                            height: 137,
                            margin: EdgeInsets.only(top: 10, bottom: 5),
                            child: BlocBuilder<GetAppBloc, GetAppState>(
                              builder: (context, state) {
                                if (state is GetAppLoaded) {
                                  late List<AppUsageInfo> data;
                                  if (state.appUsage.length >= 4) {
                                    data = [
                                      state.appUsage[0],
                                      state.appUsage[1],
                                      state.appUsage[2],
                                      state.appUsage[3],
                                    ];
                                  } else {
                                    data = state.appUsage;
                                  }
                                  return Wrap(
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    spacing: 15,
                                    runSpacing: 15,
                                    children:
                                        data.map((t) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (packages.contains(
                                                t.packageName,
                                              )) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => CameraPage(
                                                        package: t.packageName,
                                                      ),
                                                );
                                              } else {
                                                context.read<lb.LockBloc>().add(
                                                  lb.TempLockAppEvent(
                                                    t.packageName,
                                                    tempPackages,
                                                  ),
                                                );
                                              }
                                            },
                                            child: BlocBuilder<
                                              lb.LockBloc,
                                              lb.LockState
                                            >(
                                              builder: (context, state_) {
                                                if (state_ is lb.LockLoaded) {
                                                  tempPackages = state_.package;
                                                  debugPrint(
                                                    "Packages1: $packages",
                                                  );
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      // color: const Color(0xFFe35655),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            [
                                                              Colors.red,
                                                              Colors.blue,
                                                              Colors.green,
                                                              Colors.yellow,
                                                              Colors.orange,
                                                            ][data.indexOf(t) %
                                                                5],
                                                        width: 5,
                                                      ),
                                                    ),
                                                    width: 50,
                                                    height: 50,
                                                    child:
                                                        packages.contains(
                                                                  t.packageName,
                                                                ) ||
                                                                tempPackages
                                                                    .contains(
                                                                      t.packageName,
                                                                    )
                                                            ? Badge(
                                                              offset: Offset(
                                                                0,
                                                                -1,
                                                              ),
                                                              smallSize: 10,
                                                              backgroundColor:
                                                                  [
                                                                    Colors.red,
                                                                    Colors.blue,
                                                                    Colors
                                                                        .green,
                                                                    Colors
                                                                        .yellow,
                                                                    Colors
                                                                        .orange,
                                                                  ][data.indexOf(
                                                                        t,
                                                                      ) %
                                                                      5],
                                                              child: Image.memory(
                                                                state.apps
                                                                        .where((
                                                                          e,
                                                                        ) {
                                                                          return data !=
                                                                                  null &&
                                                                              data.isNotEmpty &&
                                                                              e.packageName ==
                                                                                  t.packageName;
                                                                        })
                                                                        .firstOrNull
                                                                        ?.icon ??
                                                                    Uint8List(
                                                                      0,
                                                                    ),
                                                              ),
                                                            )
                                                            : Image.memory(
                                                              state.apps
                                                                      .where((
                                                                        e,
                                                                      ) {
                                                                        return data !=
                                                                                null &&
                                                                            data.isNotEmpty &&
                                                                            e.packageName ==
                                                                                t.packageName;
                                                                      })
                                                                      .firstOrNull
                                                                      ?.icon ??
                                                                  Uint8List(0),
                                                            ),
                                                  );
                                                }
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    // color: const Color(0xFFe35655),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          [
                                                            Colors.red,
                                                            Colors.blue,
                                                            Colors.green,
                                                            Colors.yellow,
                                                            Colors.orange,
                                                          ][data.indexOf(t)],
                                                      width: 5,
                                                    ),
                                                  ),
                                                  width: 50,
                                                  height: 50,
                                                  child: Image.memory(
                                                    state.apps
                                                            .where((e) {
                                                              return data !=
                                                                      null &&
                                                                  data.isNotEmpty &&
                                                                  e.packageName ==
                                                                      t.packageName;
                                                            })
                                                            .firstOrNull
                                                            ?.icon ??
                                                        Uint8List(0),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                  );
                                } else if (state is GetAppLoading) {
                                  return Center(child: Text("Loading..."));
                                }
                                return Container(child: Text("Error"));
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 217, 217, 217),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 73,
                            width: width * 0.43,
                            margin: EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,

                                  child: PageView(
                                    onPageChanged: (value) {
                                      selectedMethod = value;
                                    },
                                    controller: controller,
                                    children: [
                                      Center(
                                        child: Text(
                                          "Camera",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Timer",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SmoothPageIndicator(
                                  controller: controller,
                                  count: 2,
                                  effect: WormEffect(
                                    dotHeight: 10,
                                    dotWidth: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(217, 217, 217, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: height * 0.5,
                  width: width * 0.9,
                  child: Column(
                    children: [
                      Text(
                        "Available Apps",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),

                      BlocBuilder<GetAppBloc, GetAppState>(
                        builder: (context, state) {
                          if (state is GetAppLoaded) {
                            apps = state.apps;

                            return Flexible(
                              child: ListView.builder(
                                itemCount: apps.length,
                                itemBuilder:
                                    (context, index) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromRGBO(75, 75, 75, 1),
                                      ),
                                      margin: EdgeInsets.only(
                                        top: 5,
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          apps[index].name ?? "",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          apps[index].packageName,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Image.memory(
                                          apps[index].icon ?? Uint8List(0),
                                        ),
                                        trailing: BlocBuilder<
                                          lb.LockBloc,
                                          lb.LockState
                                        >(
                                          builder: (context, state) {
                                            if (state is lb.LockLoaded) {
                                              tempPackages = state.package;
                                              debugPrint(
                                                "Packages1: $packages",
                                              );
                                              return IconButton(
                                                icon: Icon(
                                                  packages.contains(
                                                            apps[index]
                                                                .packageName,
                                                          ) ||
                                                          tempPackages.contains(
                                                            apps[index]
                                                                .packageName,
                                                          )
                                                      ? Icons.lock
                                                      : Icons.lock_open,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  debugPrint(
                                                    "Packages: $packages",
                                                  );
                                                  if (packages.contains(
                                                    apps[index].packageName,
                                                  )) {
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => CameraPage(
                                                            package:
                                                                apps[index]
                                                                    .packageName,
                                                          ),
                                                    );
                                                  } else {
                                                    context
                                                        .read<lb.LockBloc>()
                                                        .add(
                                                          lb.TempLockAppEvent(
                                                            apps[index]
                                                                .packageName,
                                                            tempPackages,
                                                          ),
                                                        );
                                                  }
                                                },
                                              );
                                            }
                                            return IconButton(
                                              icon: Icon(
                                                packages.contains(
                                                          apps[index]
                                                              .packageName,
                                                        ) ||
                                                        tempPackages.contains(
                                                          apps[index]
                                                              .packageName,
                                                        )
                                                    ? Icons.lock
                                                    : Icons.lock_open,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                if (packages.contains(
                                                  apps[index].packageName,
                                                )) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) => CameraPage(
                                                          package:
                                                              apps[index]
                                                                  .packageName,
                                                        ),
                                                  );
                                                } else {
                                                  context
                                                      .read<lb.LockBloc>()
                                                      .add(
                                                        lb.TempLockAppEvent(
                                                          apps[index]
                                                              .packageName,
                                                          tempPackages,
                                                        ),
                                                      );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            );
                          } else if (state is GetAppLoading) {
                            return Text("We are fetching your apps...");
                          }
                          return Container(child: Text("Error"));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 10),
            child: TextButton(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(width * 0.9, 50)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () async {
                if (selectedMethod == 0) {
                  for (var i in tempPackages) {
                    await LockAppService.instance.lockApp(i);
                  }
                  SystemNavigator.pop();
                  return;
                } else {
                  // TODO: MAKE IT CORRECT
                  showDialog(
                    context: context,
                    builder:
                        (context) => Dialog(
                          child: Container(
                            height: height * 0.8,
                            child: TimerPage(packageName: tempPackages.first),
                          ),
                        ),
                  );
                }
              },
              child: Text("Lock", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
