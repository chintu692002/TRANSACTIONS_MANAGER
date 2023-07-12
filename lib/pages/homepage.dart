import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/add_transactions.dart';
import 'package:money_manager/controller/db_helper.dart';
import 'package:money_manager/modals/transaction_model.dart';
import 'package:money_manager/pages/widgets/confirm_dialog.dart';
import 'package:money_manager/static.dart' as Static;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DbHelper dbHelper = DbHelper();
  DateTime today = DateTime.now();
  late SharedPreferences preferences;
  late Box box;
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  List<FlSpot> dataSet = [];
  List<FlSpot> getPlotPoints(List<TransactionModal> entireData) {
    dataSet = [];
    // entireData.forEach((key, value) {
    //   if (value['type'] == "Expense" &&
    //       (value['date'] as DateTime).month == today.month) {
    //     dataSet.add(
    //       FlSpot(
    //         (value['date'] as DateTime).day.toDouble(),
    //         (value['amount'] as int).toDouble(),
    //       ),
    //     );
    //   }
    // });
    List tempDataSet = [];
    for (TransactionModal data in entireData) {
      if (data.date.month == today.month && data.type == "Expense") {
        tempDataSet.add(data);
      }
    }
    tempDataSet.sort((a, b) => a.date.day.compareTo(b.date.day));
    for (var i = 0; i < tempDataSet.length; i++) {
      dataSet.add(FlSpot(tempDataSet[i].date.day.toDouble(),
          tempDataSet[i].amount.toDouble()));
    }
    return dataSet;
  }

  getTotalBalance(List<TransactionModal> entireData) {
    totalBalance = 0;
    totalExpense = 0;
    totalIncome = 0;
    for (TransactionModal data in entireData) {
      if (data.date.month == today.month) {
        if (data.type == "Income") {
          totalBalance += data.amount;
          totalIncome += data.amount;
        } else {
          totalBalance -= data.amount;
          totalExpense += data.amount;
        }
      }
    }
  }

  getPreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<List<TransactionModal>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      List<TransactionModal> items = [];
      box.toMap().values.forEach((element) {
        items.add(
          TransactionModal(element['amount'] as int,
              element['date'] as DateTime, element['note'], element['type']),
        );
      });
      return items;
    }
  }

  @override
  void initState() {
    super.initState();
    getPreference();
    box = Hive.box('money');
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => AddTransaction(),
                ),
              )
              .whenComplete(() => setState(
                    () {},
                  ));
        },
        backgroundColor: Static.PrimaryMaterialColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
      body: FutureBuilder<List<TransactionModal>>(
        future: fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Unexpected Error!"),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Text("No values Found !"),
              );
            }
            getTotalBalance(snapshot.data!);
            getPlotPoints(snapshot.data!);
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                32.0,
                              ),
                            ),
                            child: Icon(
                              Icons.face,
                              size: 32.0,
                              color: Color(0xff3E454C),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            "Welcome ${preferences.getString('name')}",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                              color: Static.PrimaryMaterialColor[800],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ),
                          color: Colors.white70,
                        ),
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.settings,
                          size: 32.0,
                          // color: Colors(0xff3E454C),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.all(
                    12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Static.PrimaryMaterialColor,
                          Colors.blueAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          24.0,
                        ),
                      ),
                    ),
                    // padding: EdgeInsets.symmetric(
                    //   vertical: 20.0,
                    //   horizontal: 120.0,
                    // ),
                    child: Column(
                      children: [
                        Text(
                          "Total Balance",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          "Rs $totalBalance",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                          //  width: 8.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                            8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: cardIncome(
                                  totalIncome.toString(),
                                ),
                              ),
                              Container(
                                child: cardExpense(
                                  totalExpense.toString(),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Expenses",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                dataSet.length < 2
                    ? Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 5,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              )
                            ]),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 40.0,
                        ),
                        margin: EdgeInsets.all(
                          12.0,
                        ),
                        // height: 400.0,
                        child: Text("Not enough data!"),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 5,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              )
                            ]),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 40.0,
                        ),
                        margin: EdgeInsets.all(
                          12.0,
                        ),
                        height: 400.0,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: getPlotPoints(snapshot.data!),
                                isCurved: false,
                                barWidth: 2.5,
                                //  color: [Static.PrimaryMaterialColor],
                              ),
                            ],
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    TransactionModal dataAtIndex = snapshot.data![index];
                    if (dataAtIndex.type == "Income") {
                      return incomeTile(
                        dataAtIndex.amount,
                        dataAtIndex.note,
                        dataAtIndex.date,
                        index,
                      );
                    } else {
                      return expenseTile(
                        dataAtIndex.amount,
                        dataAtIndex.note,
                        dataAtIndex.date,
                        index,
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 50.0,
                ),
              ],
            );
          } else {
            return Center(
              child: Text("Unexoected error !"),
            );
          }
        },
      ),
    );
  }

  Widget cardIncome(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(
            6.0,
          ),
          child: Icon(
            Icons.arrow_downward,
            size: 26.0,
            color: Colors.green[700],
          ),
          margin: EdgeInsets.only(
            right: 8.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Income",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget cardExpense(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(
            6.0,
          ),
          child: Icon(
            Icons.arrow_upward,
            size: 26.0,
            color: Colors.red,
          ),
          margin: EdgeInsets.only(
            right: 8.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Credit",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget expenseTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
            context, "WARNING", "Do you want to delete this record?");
        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(
          8.0,
        ),
        padding: EdgeInsets.all(
          8.0,
        ),
        decoration: BoxDecoration(
          color: Color(
            0xffced4eb,
          ),
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.arrow_circle_up_outlined,
                      size: 26.0,
                      color: Colors.red[700],
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      "  Debited",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: TextStyle(
                    color: Colors.grey[900],
                    // fontSize: 24.0,
                    // fontWeight: FontWeight.w700,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "- $value",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      note,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget incomeTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
            context, "WARNING", "Do you want to delete this record?");
        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        };
      },
      child: Container(
        margin: EdgeInsets.all(
          8.0,
        ),
        padding: EdgeInsets.all(
          8.0,
        ),
        decoration: BoxDecoration(
          color: Color(
            0xffced4eb,
          ),
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.arrow_circle_down_outlined,
                      size: 26.0,
                      color: Colors.green[700],
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      "  Credited",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${date.month}/${date.month}/${date.year}",
                  style: TextStyle(
                    color: Colors.grey[900],
                    // fontSize: 24.0,
                    // fontWeight: FontWeight.w700,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "+ $value",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      note,
                      style: TextStyle(
                        color: Colors.grey[900],
                        // fontSize: 24.0,
                        // fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
