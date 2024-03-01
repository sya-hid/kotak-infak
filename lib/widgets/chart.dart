import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  String dataBy = 'donatur';
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.allData();

    List<TransaksiModel> transaksiModel = transactionProvider.transaksi
        .where((element) => element.nominal != 0)
        .toList();
    authProvider.user.level == 'Petugas'
        ? transaksiModel = transaksiModel
            .where((element) => element.petugas!.id == authProvider.user.id)
            .toList()
        : null;

    transaksiModel.isEmpty
        ? transaksiModel = transactionProvider.transaksi
            .where((element) => element.nominal != 0)
            .toList()
        : null;
    transaksiModel = transaksiModel
        .sorted((a, b) => a.createdAt!.compareTo(b.createdAt!))
        .toList();
    List<String> dates = [];
    List<LineChartBarData> lineChart_ = [];
    List<Map<String, dynamic>> lineChartColor = [];
    for (var element in transaksiModel) {
      if (!dates.contains(
          DateFormat('yyyy/MM').format(element.createdAt!.toDate()))) {
        dates.add(
          DateFormat('yyyy/MM').format(
            element.createdAt!.toDate(),
          ),
        );
      }
    }
    Map<String, dynamic> newData = groupBy(
        transaksiModel,
        (p0) => dataBy == 'donatur'
            ? p0.donatur!.id!
            : dataBy == 'category'
                ? p0.donatur!.category!
                : p0.petugas!.id!).map(
      (key, value) => MapEntry(
        key,
        value.groupSetsBy(
          (element) => DateFormat('yyyy/MM').format(
            element.createdAt!.toDate(),
          ),
        ),
      ),
    );
    List<String> bottomTitles = [];
    int index = 0;
    newData.forEach((key, value) {
      List<FlSpot> spots_ = [];
      value.forEach((key_, value_) {
        if (!bottomTitles.contains(key_)) {
          bottomTitles.add(key_);
        }
        double nominal = 0;
        double newIndex = 0;
        for (var i = 0; i < dates.length; i++) {
          if (key_ == dates[i]) {
            newIndex = i.toDouble();
            nominal = value_.fold(
                0,
                (previousValue, element) =>
                    previousValue + (element.nominal)!.toDouble());
          }
        }
        spots_.add(FlSpot(newIndex, nominal));
      });
      bottomTitles = bottomTitles.sorted((a, b) => a.compareTo(b));

      String newKey;

      newKey = dataBy == 'donatur'
          ? transaksiModel
              .firstWhere((element) => element.donatur!.id == key)
              .donatur!
              .name!
          : dataBy == 'petugas'
              ? transaksiModel
                  .firstWhere((element) => element.petugas!.id == key)
                  .petugas!
                  .name!
              : key;
      key = newKey;
      Color color =
          Color(((Random(index).nextDouble() * 0.125) * 0xFFFFFFFF).toInt())
              .withOpacity(1.0);
      index++;

      lineChartColor.add({'key': key, 'color': color});
// print('indomaret'.substring(0,))
      lineChart_.add(
        LineChartBarData(
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          spots: spots_,
          isCurved: true,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.1),
          ),
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) {
              return true;
            },
          ),
          preventCurveOverShooting: true,
          preventCurveOvershootingThreshold: 20,
          color: color,
        ),
      );
    });
    return transaksiModel.isNotEmpty
        ? Column(
            children: [
              Row(
                children: [
                  DropdownButton(
                    value: dataBy,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'donatur',
                        child: Text('By Donatur'),
                      ),
                      DropdownMenuItem(
                        value: 'category',
                        child: Text('By Category'),
                      ),
                      DropdownMenuItem(
                        value: 'petugas',
                        child: Text('By Petugas'),
                      ),
                    ],
                    onChanged: (value) {
                      dataBy = value!;
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      children: lineChartColor.mapIndexed((index, e) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e['key'].substring(0,
                                  e['key'].length > 25 ? 25 : e['key'].length),
                              // e['key'].split(' ')[0],
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              height: 5,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: e['color'],
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                clipBehavior: Clip.none,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 5, top: 20, bottom: 5, right: 20),
                  child: AspectRatio(
                    aspectRatio: 16 / 8,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            showOnTopOfTheChartBoxArea: false,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((e) {
                                return LineTooltipItem(
                                  '${lineChartColor[e.barIndex]['key']} ${currencyFormatter.format(e.y)}',
                                  TextStyle(
                                    color: e.bar.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                          border: const Border(
                            bottom: BorderSide(),
                            left: BorderSide(),
                          ),
                        ),
                        lineBarsData: [...lineChart_.map((e) => e)],
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  fitInside: const SideTitleFitInsideData(
                                      enabled: true,
                                      axisPosition: 0,
                                      parentAxisSize: 0,
                                      distanceFromEdge: 0),
                                  child: Text(
                                    NumberFormat.compactCurrency(
                                            locale: 'id_ID', symbol: '')
                                        .format(value),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              interval: 1,
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String newPattern = 'MMM/yy';
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    DateFormat(newPattern, 'id_ID').format(
                                      DateTime(
                                          int.parse(bottomTitles[value.toInt()]
                                              .toString()
                                              .split('/')[0]),
                                          int.parse(bottomTitles[value.toInt()]
                                              .toString()
                                              .split('/')[1]),
                                          1),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}
